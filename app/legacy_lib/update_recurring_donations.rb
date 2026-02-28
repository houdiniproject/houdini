# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateRecurringDonations
  # Update the card id and name for a given recurring donation (provide rd['donation_id'])
  def self.update_card_id(rd, token)
    rd = rd&.with_indifferent_access
    ParamValidation.new({rd: rd, token: token},
      rd: {is_hash: true, required: true},
      token: {format: UUID::Regex, required: true})

    ParamValidation.new(rd,
      id: {is_reference: true, required: true})

    source_token = QuerySourceToken.get_and_increment_source_token(token, nil)
    tokenizable = source_token.tokenizable

    entities = RetrieveActiveRecordItems.retrieve_from_keys(rd, RecurringDonation => :id)

    validate_entities(entities[:id], tokenizable)

    Qx.transaction do
      rec_don = entities[:id]
      donation = rec_don.donation
      # TODO: This is stupid but the two are used together inconsistently. We should scrap one or the other.
      donation.card = tokenizable
      rec_don.card_id = tokenizable

      rec_don.n_failures = 0
      rec_don.save!
      donation.save!
      InsertSupporterNotes.create([{content: "This supporter updated their card for their recurring donation with ID #{rec_don.id}", supporter_id: rec_don.supporter.id, user_id: 540}])
    end
    QueryRecurringDonations.fetch_for_edit(rd[:id])["recurring_donation"]
  end

  # Update the paydate for a given recurring donation (provide rd['id'])
  def self.update_paydate(rd, paydate)
    return ValidationError.new(["Invalid paydate"]) unless (1..28).cover?(paydate.to_i)

    Psql.execute(Qexpr.new.update(:recurring_donations, paydate: paydate).where("id=$id", id: rd["id"]))
    recurring_donation = RecurringDonation.find(rd["id"])
    recurring_donation.recurrence.publish_updated
    rd["paydate"] = paydate
    rd
  end

  # @param [RecurringDonation] rd
  # @param [String] token
  # @param [Integer] amount
  def self.update_amount(rd, token, amount)
    ParamValidation.new({amount: amount, rd: rd, token: token},
      amount: {is_integer: true, min: 50, required: true},
      rd: {required: true, is_a: RecurringDonation},
      token: {required: true, format: UUID::Regex})
    source_token = QuerySourceToken.get_and_increment_source_token(token, nil)
    tokenizable = source_token.tokenizable

    validate_entities(rd, tokenizable)

    previous_amount = rd.amount
    donation = rd.donation
    Qx.transaction do
      # TODO: This is stupid but the two are used together inconsistently. We should scrap one or the other.
      rd.card = tokenizable
      rd.amount = amount
      rd.n_failures = 0
      donation.card = tokenizable
      donation.amount = amount
      rd.recurrence.amount = amount
      rd.recurrence.save!
      rd.recurrence.publish_updated
      rd.save!
      donation.save!
    end
    RecurringDonationChangeAmountJob.perform_later(rd, previous_amount)
    rd
  end

  def self.update_from_start_dates
    RecurringDonation.inactive.where("start_date >= ?", Date.today).update_all(active: true)
  end

  def self.update_from_end_dates
    RecurringDonation.active.where("end_date < ?", Date.today).update_all(active: false)
  end

  # Cancel a recurring donation (set active='f') and record the supporter/user email who did it
  def self.cancel(rd_id, email, dont_notify_nonprofit = false)
    Psql.execute(
      Qexpr.new.update(:recurring_donations,
        active: false,
        cancelled_by: email,
        cancelled_at: Time.current)
      .where("id=$id", id: rd_id.to_i)
    )
    rd = QueryRecurringDonations.fetch_for_edit(rd_id)["recurring_donation"]
    InsertSupporterNotes.create({supporter: Supporter.find(rd["supporter_id"]), user: nil, content: "This supporter's recurring donation for $#{Format::Currency.cents_to_dollars(rd["amount"])} was cancelled by #{rd["cancelled_by"]} on #{Format::Date.simple(rd["cancelled_at"])}"})
    unless dont_notify_nonprofit
      RecurringDonationCancelledJob.perform_later(Donation.find(rd["donation_id"]))
    end
    rd
  end

  def self.update(rd, params)
    params = set_defaults(params)
    if params[:donation]
      rd.donation.update(params[:donation])
      return rd.donation unless rd.donation.valid?

      params = params.except(:donation)
    end

    rd.update(params)
    rd
  end

  def self.set_defaults(params)
    if params[:donation] && params[:donation][:dollars]
      params[:donation][:amount] = Format::Currency.dollars_to_cents(params[:donation][:dollars])
      params[:donation] = params[:donation].except(:dollars)
      params[:amount] = params[:donation][:amount]
    end

    if params[:end_date_str]
      params[:end_date] = if params[:end_date_str].blank? || params[:end_date_str] == "None"
        nil
      else
        Chronic.parse(params[:end_date_str])
      end
      params = params.except(:end_date_str)
    end

    params
  end

  # @param [RecurringDonation] rd
  # @param [Card] tokenizable
  def self.validate_entities(rd, tokenizable)
    if rd.cancelled_at
      raise ParamValidation::ValidationError.new("Recurring Donation #{rd.id} is already cancelled.", key: :id)
    end

    if tokenizable.deleted
      raise ParamValidation::ValidationError.new("Tokenized card #{tokenizable.id} is not valid.", key: :token)
    end

    if tokenizable.holder != rd.supporter
      raise ParamValidation::ValidationError.new("Supporter #{rd.supporter.id} does not own card #{tokenizable.id}", key: :token)
    end
  end
end
