# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertDonation


  # Make a one-time donation (call InsertRecurringDonation.with_stripe to create a recurring donation)
  # In data, pass in:
  # amount, card_id, nonprofit_id, supporter_id
  # designation, dedication
  # recurring_donation if is recurring
  def self.with_stripe(data, current_user=nil)
    data = data.to_deprecated_h.with_indifferent_access

    ParamValidation.new(data, common_param_validations
                                  .merge(token: {required: true, format: UUID::Regex}))

    source_token = QuerySourceToken.get_and_increment_source_token(data[:token], current_user)
    tokenizable = source_token.tokenizable
    QuerySourceToken.validate_source_token_type(source_token)

    entities =  RetrieveActiveRecordItems.retrieve_from_keys(data, {Supporter => :supporter_id, Nonprofit => :nonprofit_id})

    entities = entities.merge(RetrieveActiveRecordItems.retrieve_from_keys(data, {Campaign => :campaign_id, Event => :event_id, Profile => :profile_id}, true))

    validate_entities(entities)

    ## does the card belong to the supporter?
    if tokenizable.holder != entities[:supporter_id]
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} does not own card #{tokenizable.id}", key: :token)
    end

    data['card_id'] = tokenizable.id

    result = {}

    data[:date] = Time.now
    data = amount_from_data(data)
    data = data.except(:old_donation).except('old_donation')
    result = result.merge(insert_charge(data))
    if result['charge']['status'] == 'failed'
      raise ChargeError.new(result['charge']['failure_message'])
    end
    # Create the donation record
    result['donation'] = self.insert_donation(data, entities)
    trx = entities[:supporter_id].transactions.build(amount: data['amount'], created: data['date'])
    update_donation_keys(result)
    don = trx.donations.build(amount: result['donation'].amount, legacy_donation: result['donation'])
    legacy_payment = Payment.find(result['payment']['id'])
    stripe_transaction_charge = SubtransactionPayment.new(
      legacy_payment: legacy_payment,
      paymentable: StripeTransactionCharge.new,
      created: legacy_payment.date
    )
    stripe_t = trx.build_subtransaction(
      subtransactable: StripeTransaction.new(amount: data['amount']), 
      subtransaction_payments:[
        stripe_transaction_charge
      ]
    );
    trx.save!
    don.save!
    stripe_t.save!
    stripe_t.subtransaction_payments.each(&:publish_created)
    #stripe_t.publish_created
    don.publish_created
    trx.publish_created
    result['activity'] = InsertActivities.for_one_time_donations([result['payment'].id])
    JobQueue.queue(JobTypes::DonationPaymentCreateJob, result['donation'].id, result['payment'].id, entities[:supporter_id].locale)
    result
  end

  # Update the charge to have the payment and donation id
  # Update the payment to have the donation id
  def self.update_donation_keys(result)
    result['charge'].donation = result['donation']
    result['charge'].save!

    result['payment'].donation = result['donation']
    result['payment'].save!
  end

  # Insert a donation made from an offsite payment
  # Creates an offsite payment, payment, and donation
  # pass in amount, nonprofit_id, supporter_id, check_number
  # also pass in offsite_payment sub-hash (can be empty)
  def self.offsite(data)
    ParamValidation.new(data, common_param_validations.merge(offsite_payment: {is_hash: true}))

    entities = RetrieveActiveRecordItems.retrieve_from_keys(data, {Supporter => :supporter_id, Nonprofit => :nonprofit_id})
    entities = entities.merge(RetrieveActiveRecordItems.retrieve_from_keys(data, {Campaign => :campaign_id, Event => :event_id, Profile => :profile_id}, true))
    validate_all_entities(entities)

    data = amount_from_data(date_from_data(data))
    result = {'donation' => self.insert_donation(data.except('offsite_payment'), entities)}
    trx = entities[:supporter_id].transactions.build(amount: data['amount'], created: data['date'])
    don = trx.donations.build(amount: result['donation'].amount, legacy_donation: result['donation'])
    result['payment'] = self.insert_payment('OffsitePayment', 0, result['donation']['id'], data)
    result['offsite_payment'] = Psql.execute(
      Qexpr.new.insert(:offsite_payments, [
        (data['offsite_payment']&.to_deprecated_h&.with_indifferent_access || {}).merge({
          gross_amount: data['amount'],
          nonprofit_id: data['nonprofit_id'],
          supporter_id: data['supporter_id'],
          donation_id: result['donation']['id'],
          payment_id: result['payment']['id'],
          date: data['date']
        })
      ]).returning('*')
    ).first
    legacy_payment = Payment.find(result['payment']['id'])
    offline_transaction_charge_payment = SubtransactionPayment.new(
          legacy_payment: legacy_payment,
          paymentable: OfflineTransactionCharge.new,
          created: legacy_payment.date
          )
    off_t = trx.build_subtransaction(
      subtransactable: OfflineTransaction.new(amount: data['amount']), 
      subtransaction_payments:[
        offline_transaction_charge_payment
        ],
      created: data['date']
      );
    trx.save!
    don.save!
    off_t.save!

    trx.publish_created
    don.publish_created
    # off_t.publish_created
    offline_transaction_charge_payment.publish_created

    result['activity'] = InsertActivities.for_offsite_donations([result['payment']['id']])
  
    return {status: 200, json: result}
  end

  def self.with_sepa(data)
    data = data.to_deprecated_h.with_indifferent_access
    ParamValidation.new(data, common_param_validations
                                 .merge(direct_debit_detail_id: {required: true, is_reference: true}))

    entities =  RetrieveActiveRecordItems.retrieve_from_keys(data, {Supporter => :supporter_id, Nonprofit => :nonprofit_id})

    entities = entities.merge(RetrieveActiveRecordItems.retrieve_from_keys(data, {Campaign => :campaign_id, Event => :event_id, Profile => :profile_id}, true))

    result = {}

    data[:date] = Time.now
    result = result.merge(insert_charge(data))
    result['donation'] = self.insert_donation(data, entities)
    update_donation_keys(result)

    JobQueue.queue(JobTypes::NonprofitPaymentNotificationJob, result['donation'].id, result['donation'].payment.id)
    JobQueue.queue(JobTypes::DonorDirectDebitNotificationJob, result['donation'].id, result['donation'].supporter.locale)
    # do this for making test consistent
    result['activity'] = {}
    result
  end

private

  def self.get_nonprofit_data(nonprofit_id)
    Nonprofit.find(nonprofit_id)
  end

  def self.insert_charge(data)
    payment_provider = payment_provider(data)
    nonprofit_data = get_nonprofit_data(data['nonprofit_id'])
    kind = data['recurring_donation'] ? "RecurringDonation" : "Donation"
    if payment_provider == 'credit_card'
      return InsertCharge.with_stripe({
        donation_id: data['donation_id'],
        kind: kind,
        towards: data['designation'],
        metadata: {kind: kind, nonprofit_id: data['nonprofit_id']},
        statement: "Donation #{nonprofit_data['statement'] || nonprofit_data['name']}",
        amount: data['amount'],
        nonprofit_id: data['nonprofit_id'],
        supporter_id: data['supporter_id'],
        card_id: data['card_id'],
        old_donation: data['old_donation'] ? true : false,
        fee_covered: data['fee_covered']
      })
    elsif payment_provider == 'sepa'
      return InsertCharge.with_sepa({
        donation_id: data['donation_id'],
        kind: kind,
        towards: data['designation'],
        metadata: {kind: kind, nonprofit_id: data['nonprofit_id']},
        statement: "Donation #{nonprofit_data['statement'] || nonprofit_data['name']}",
        amount: data['amount'],
        nonprofit_id: data['nonprofit_id'],
        supporter_id: data['supporter_id'],
        direct_debit_detail_id: data['direct_debit_detail_id']
      })
    end
  end

  # Insert a payment row for a donation
  def self.insert_payment(kind, fee_total, donation_id, data)
    Psql.execute(
      Qexpr.new.insert(:payments, [{
        donation_id: donation_id,
        gross_amount: data['amount'],
        nonprofit_id: data['nonprofit_id'],
        supporter_id: data['supporter_id'],
        refund_total: 0,
        date: data['date'],
        towards: data['designation'],
        kind: kind,
        fee_total: fee_total,
        net_amount: data['amount'] - fee_total
      }]).returning('*')
    ).first
  end

  # Insert a donation row
  def self.insert_donation(data, entities)
    d = Donation.new
    d.date = data['date']
    d.anonymous = data['anonymous']
    d.designation = data['designation']
    d.dedication = data['dedication']
    d.comment = data['comment']
    d.amount = data['amount']
    d.card = Card.find(data['card_id']) if data['card_id']
    d.direct_debit_detail = DirectDebitDetail.find(data['direct_debit_detail_id']) if data['direct_debit_detail_id']
    d.nonprofit = entities[:nonprofit_id]
    d.supporter = entities[:supporter_id]
    d.profile = entities[:profile_id] || nil
    d.campaign = entities[:campaign_id] || nil
    d.event = entities[:event_id] || nil
    d.payment_provider = payment_provider(data).to_s
    d.save!
    d
  end

  # Return either the parsed DateTime from a date in data, or right now
  def self.date_from_data(data)
    data.merge('date' => data['date'].blank? ? Time.current : Chronic.parse(data['date']))
  end

  def self.amount_from_data(data)
    data.merge('amount' => data['amount'].to_i)
  end

  def self.payment_provider(data)
    if data[:card_id] || data["card_id"]
      'credit_card'
    elsif data[:direct_debit_detail_id] || data["direct_debit_detail_id"]
      'sepa'
    end
  end

def self.parse_date(date)
    date.blank? ? Time.current : Chronic.parse(date)
  end

  def self.common_param_validations
    {
        amount: {required: true, is_integer: true},
        nonprofit_id: {required: true, is_reference: true},
        supporter_id: {required: true, is_reference: true},
        designation: {is_a: String},
        dedication: {is_a: String},
        campaign_id: {is_reference: true},
        event_id: {is_reference: true},
    }
  end

  def self.validate_entities(entities)
    unless entities[:nonprofit_id].can_process_charge?
      raise ParamValidation::ValidationError.new("Nonprofit #{entities[:nonprofit_id].id} is not allowed to process charges", key: :nonprofit_id)
    end
    validate_all_entities(entities)
  end

  def self.validate_all_entities(entities)
    ## is supporter deleted? If supporter is deleted, we error!
    if entities[:supporter_id].deleted
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} is deleted", key: :supporter_id)
    end

    if entities[:event_id] && entities[:event_id].deleted
      raise ParamValidation::ValidationError.new("Event #{entities[:event_id].id} is deleted", key: :event_id)
    end

    if entities[:campaign_id] && entities[:campaign_id].deleted
      raise ParamValidation::ValidationError.new("Campaign #{entities[:campaign_id].id} is deleted", key: :campaign_id)
    end

    # Does the supporter belong to the nonprofit?
    if entities[:supporter_id].nonprofit != entities[:nonprofit_id]
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} does not belong to nonprofit #{entities[:nonprofit_id].id}", key: :supporter_id)
    end

    ### if we have campaign, does it belong to nonprofit
    if entities[:campaign_id] && entities[:campaign_id].nonprofit != entities[:nonprofit_id]
      raise ParamValidation::ValidationError.new("Campaign #{entities[:campaign_id].id} does not belong to nonprofit #{entities[:nonprofit_id]}", key: :campaign_id)
    end

    ## if we have event, does it belong to nonprofit
    if entities[:event_id] && entities[:event_id].nonprofit != entities[:nonprofit_id]
      raise ParamValidation::ValidationError.new("Event #{entities[:event_id].id} does not belong to nonprofit #{entities[:nonprofit_id]}", key: :event_id)
    end
  end
end
