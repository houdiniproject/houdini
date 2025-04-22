# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertRecurringDonation
  # Create a recurring_donation, donation, payment, charge, and activity
  # See controllers/nonprofits/recurring_donations_controller#create for the data params to pass in
  def self.with_stripe(data)
    data = data.with_indifferent_access

    ParamValidation.new(data, InsertDonation.common_param_validations
                                  .merge(token: {required: true, format: UUID::Regex}))

    if data[:recurring_donation].nil?
      data[:recurring_donation] = {}
    else

      ParamValidation.new(data[:recurring_donation],
        interval: {is_integer: true},
        start_date: {can_be_date: true},
        time_unit: {included_in: %w[month day week year]},
        paydate: {is_integer: true})
      if data[:recurring_donation][:paydate]
        data[:recurring_donation][:paydate] = data[:recurring_donation][:paydate].to_i
      end

      ParamValidation.new(data[:recurring_donation],
        paydate: {min: 1, max: 28})

    end

    source_token = QuerySourceToken.get_and_increment_source_token(data[:token], nil)
    tokenizable = source_token.tokenizable
    QuerySourceToken.validate_source_token_type(source_token)

    entities = RetrieveActiveRecordItems.retrieve_from_keys(data, Supporter => :supporter_id, Nonprofit => :nonprofit_id)

    entities = entities.merge(RetrieveActiveRecordItems.retrieve_from_keys(data, {Campaign => :campaign_id, Event => :event_id, Profile => :profile_id}, true))

    InsertDonation.validate_entities(entities)

    ## does the card belong to the supporter?
    if tokenizable.holder != entities[:supporter_id]
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} does not own card #{tokenizable.id}", key: :token)
    end

    data["card_id"] = tokenizable.id

    result = {}
    data[:date] = Time.now
    data = data.merge(payment_provider: payment_provider(data))
    data = data.except(:old_donation).except("old_donation")
    # if start date is today, make initial charge first
    test_start_date = get_test_start_date(data)
    if test_start_date.nil? || Time.current >= test_start_date
      result = result.merge(InsertDonation.insert_charge(data))
      if result["charge"]["status"] == "failed"
        raise ChargeError, result["charge"]["failure_message"]
      end
    end

    # Create the donation record
    result["donation"] = InsertDonation.insert_donation(data, entities)
    entities[:donation_id] = result["donation"]
    # Create the recurring_donation record
    result["recurring_donation"] = insert_recurring_donation(data, entities)
    # Update charge foreign keys
    if result["payment"]
      InsertDonation.update_donation_keys(result)

      trx = entities[:supporter_id].transactions.build(amount: data["amount"], created: data["date"])
      don = trx.donations.build(amount: result["donation"].amount, legacy_donation: result["donation"])
      stripe_t = trx.build_subtransaction(
        subtransactable: StripeTransaction.new(amount: data["amount"]),
        payments: [
          SubtransactionPayment.new(
            paymentable: StripeCharge.new(payment: Payment.find(result["payment"]["id"]))
          )
        ],
        created: data["date"]
      )
      trx.save!
      don.save!
      stripe_t.save!
      stripe_t.payments.each(&:publish_created)
      stripe_t.publish_created
      don.publish_created
      trx.publish_created

      # Create the activity record
      result["activity"] = InsertActivities.for_recurring_donations([result["payment"].id])
    end

    recurrence = result["recurring_donation"].create_recurrence!(supporter: result["recurring_donation"].supporter, start_date: result["recurring_donation"].start_date, amount: result["recurring_donation"].amount)
    recurrence.publish_created
    # Send receipts
    Houdini.event_publisher.announce(:recurring_donation_create, result["donation"], entities[:supporter_id].locale)
    result
  end

  def self.with_sepa(data)
    data = set_defaults(data)
    data = data.merge(payment_provider: payment_provider(data))
    result = {}

    if Time.current >= data[:recurring_donation][:start_date]
      result = result.merge(InsertDonation.insert_charge(data))
    end

    result["donation"] = Psql.execute(Qexpr.new.insert(:donations, [
      data.except(:recurring_donation)
    ]).returning("*")).first

    result["recurring_donation"] = Psql.execute(Qexpr.new.insert(:recurring_donations, [
      data[:recurring_donation].merge(donation_id: result["donation"]["id"])
    ]).returning("*")).first

    InsertDonation.update_donation_keys(result) if result["payment"]

    Houdini.event_publisher.announce(:recurring_donation_create, result["donation"], entities[:supporter_id].locale)

    {status: 200, json: result}
  end

  # the data model here is brutal. This needs to get cleaned up.
  def self.convert_donation_to_recurring_donation(donation_id)
    ParamValidation.new({donation_id: donation_id}, donation_id: {required: true, is_integer: true})
    don = Donation.where("id = ? ", donation_id).first
    unless don
      raise ParamValidation::ValidationError.new("#{donation_id} is not a valid donation", key: :donation_id, val: donation_id)
    end

    rd = insert_recurring_donation({amount: don.amount, email: don.supporter.email, anonymous: don.anonymous, origin_url: don.origin_url, recurring_donation: {start_date: don.created_at, paydate: convert_date_to_valid_paydate(don.created_at)}, date: don.created_at}, supporter_id: don.supporter, nonprofit_id: don.nonprofit, donation_id: don)
    don.recurring_donation = rd
    don.recurring = true

    don.payment.kind = "RecurringDonation"
    don.payment.save!
    rd.save!
    don.save!

    rd
  end

  def self.insert_recurring_donation(data, entities)
    rd = RecurringDonation.new
    rd.amount = data[:amount]
    rd.nonprofit = entities[:nonprofit_id]
    rd.donation = entities[:donation_id]
    rd.supporter_id = entities[:supporter_id].id
    rd.active = true
    rd.edit_token = SecureRandom.uuid
    rd.n_failures = 0
    rd.email = entities[:supporter_id].email
    rd.interval = (data[:recurring_donation][:interval].presence || 1)
    rd.time_unit = (data[:recurring_donation][:time_unit].presence || "month")
    rd.start_date = if data[:recurring_donation][:start_date].blank?
      Time.current.beginning_of_day
    elsif data[:recurring_donation][:start_date].is_a? Time
      data[:recurring_donation][:start_date]
    else
      Chronic.parse(data[:recurring_donation][:start_date])
    end

    rd.paydate = if rd.time_unit == "month" && rd.interval == 1 && data[:recurring_donation][:paydate].nil?
      convert_date_to_valid_paydate(rd.start_date)
    else
      data[:recurring_donation][:paydate]
    end

    rd.save!
    rd
  end

  def self.get_test_start_date(data)
    unless data[:recurring_donation] && data[:recurring_donation][:start_date]
      return nil
    end

    Chronic.parse(data[:recurring_donation][:start_date])
  end

  def self.payment_provider(data)
    if data[:card_id]
      :credit_card
    elsif data[:direct_debit_detail_id]
      :sepa
    end
  end

  def self.convert_date_to_valid_paydate(date)
    day = date.day
    (day > 28) ? 28 : day
  end
end
