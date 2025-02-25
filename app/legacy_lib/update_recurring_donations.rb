# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateRecurringDonations

  class UpdateModel
    include ActiveModel::Validations
    attr_accessor :amount
    validates :amount, :presence => true,  :numericality => {:greater_than_or_equal_to => 0.75}
  end

  # Update the card id and name for a given recurring donation (provide rd['donation_id'])
  def self.update_card_id(rd, token)
    rd = rd&.to_deprecated_h&.with_indifferent_access

    ParamValidation.new({rd: rd, token: token},
                        {
                            rd: {is_hash: true, required: true},
                            token: {format: UUID::Regex, required: true}
                        })

    ParamValidation.new(rd,
                        {
                            id: {is_reference: true, required: true}
                        })

    source_token = QuerySourceToken.get_and_increment_source_token(token, nil)
    tokenizable = source_token.tokenizable


    entities = RetrieveActiveRecordItems.retrieve_from_keys(rd, RecurringDonation => :id )

    validate_entities(entities[:id], tokenizable)

    Qx.transaction do
      rec_don = entities[:id]
      donation = rec_don.donation
      #TODO This is stupid but the two are used together inconsistently. We should scrap one or the other.
      donation.card = tokenizable
      rec_don.card_id = tokenizable

      rec_don.n_failures = 0
      rec_don.save!
      donation.save!
      rec_don.supporter.supporter_notes.create!( content: "This supporter updated their card for their recurring donation with ID #{rec_don.id}", user: User.find(540))
    end
    return QueryRecurringDonations.fetch_for_edit(rd[:id])['recurring_donation']
  end

  # Update the paydate for a given recurring donation (provide rd['id'])
  def self.update_paydate(rd, paydate)
    return ValidationError.new(['Invalid paydate']) unless (1..28).include?(paydate.to_i)
    Psql.execute(Qexpr.new.update(:recurring_donations, paydate: paydate).where("id=$id", id: rd['id']))
    rd['paydate'] = paydate
    return rd
  end

  # @param [RecurringDonation] rd
  # @param [String] token
  # @param [Integer] amount
  # @param [Boolean] fee_covered
  def self.update_amount(rd, token, amount, fee_covered=false)
    ParamValidation.new({amount: amount, rd: rd, token: token},
                        {amount: {is_integer: true,  min: 50, required:true},
                                  rd: {required:true, is_a: RecurringDonation},
                                  token: {required:true, format: UUID::Regex}
                        })
    source_token = QuerySourceToken.get_and_increment_source_token(token, nil)
    tokenizable = source_token.tokenizable

    validate_entities(rd, tokenizable)

    previous_amount = rd.amount
    donation = rd.donation
    Qx.transaction do
      #TODO This is stupid but the two are used together inconsistently. We should scrap one or the other.
      rd.card = tokenizable
      rd.amount = amount
      rd.n_failures= 0
      donation.card = tokenizable
      donation.amount = amount
      rd.save!
      donation.save!
      misc = rd.misc_recurring_donation_info || rd.create_misc_recurring_donation_info
      misc.fee_covered = fee_covered
      misc.save!
    end
    JobQueue.queue(JobTypes::NonprofitRecurringDonationChangeAmountJob, rd.id, previous_amount)
    JobQueue.queue(JobTypes::DonorRecurringDonationChangeAmountJob,rd.id, previous_amount)
    rd
  end


  def self.update_from_start_dates
    RecurringDonation.inactive.where("start_date >= ?", Date.today).update_all(active: true)
  end


  def self.update_from_end_dates
    RecurringDonation.active.where("end_date < ?", Date.today).update_all(active: false)
  end


  # Cancel a recurring donation (set active='f') and record the supporter/user email who did it
  def self.cancel(rd_id, email, dont_notify_nonprofit=false)
    recurring_donation = RecurringDonation.find(rd_id)
    recurring_donation.cancel!(email)

    rd = QueryRecurringDonations.fetch_for_edit(rd_id)['recurring_donation']
    Supporter.find(rd['supporter_id']).supporter_notes.create!(content: "This supporter's recurring donation for $#{Format::Currency.cents_to_dollars(rd['amount'])} was cancelled by #{rd['cancelled_by']} on #{Format::Date.simple(rd['cancelled_at'])}", user: User.find(540));
    if (!dont_notify_nonprofit)
      DonationMailer.delay.nonprofit_recurring_donation_cancellation(rd['donation_id'])
    end

    return rd
  end


  def self.update(rd, params)
    model = UpdateRecurringDonations::UpdateModel.new

    model.amount = params[:donation] && params[:donation][:dollars]

    model_valid = model.valid?
    if !model_valid
      return model
    end
    
    params = set_defaults(params)
    if params[:donation]
      rd.donation.update_attributes(params[:donation])
      return rd.donation unless rd.donation.valid?
      params = params.except(:donation)
    end

    fee_covered = params[:fee_covered]
    misc = rd.misc_recurring_donation_info || rd.create_misc_recurring_donation_info
    misc.fee_covered = fee_covered
    misc.save!
    
    params = params.except(:fee_covered)
    rd.update_attributes(params)
    return rd
  end


  def self.set_defaults(params)
    if params[:donation] && params[:donation][:dollars]
      params[:donation][:amount] = Format::Currency.dollars_to_cents(params[:donation][:dollars])
      params[:donation] = params[:donation].except(:dollars)
      params[:amount] = params[:donation][:amount]
    end

    if params[:end_date_str]
      if params[:end_date_str].blank? || params[:end_date_str] == 'None'
        params[:end_date] = nil
      else
        params[:end_date] = Chronic.parse(params[:end_date_str])
      end
      params = params.except(:end_date_str)
    end

    return params
  end

  # @param [RecurringDonation] rd
  # @param [Card] tokenizable
  def self.validate_entities(rd, tokenizable)
    if (rd.cancelled_at)
      raise ParamValidation::ValidationError.new("Recurring Donation #{rd.id} is already cancelled.", key: :id)
    end

    if (tokenizable.deleted)
      raise ParamValidation::ValidationError.new("Tokenized card #{tokenizable.id} is not valid.", key: :token)
    end

    if tokenizable.holder != rd.supporter
      raise ParamValidation::ValidationError.new("Supporter #{rd.supporter.id} does not own card #{tokenizable.id}", key: :token)
    end
  end

end

