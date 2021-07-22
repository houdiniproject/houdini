# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module InsertRefunds

  # Refund a given charge, up to its net amount
  # params: amount, donation obj
  def self.with_stripe(charge, h)
    # if Time.now < FEE_SWITCHOVER_TIME
    #   legacy_refund(charge, h)
    # else
      modern_refund(charge, h)
    # end
  end


  def self.modern_refund(charge,h)
    ParamValidation.new(charge, { 
      payment_id: {required: true, is_integer: true},
      stripe_charge_id: {required: true, format: /^(test_)?ch_.*$/},
      amount: {required: true, is_integer: true, min: 1},
      id: {required: true, is_integer: true},
      nonprofit_id: {required: true, is_integer: true},
      supporter_id: {required: true, is_integer: true}
    })
    ParamValidation.new(h, { amount: {required: true, is_integer: true, min: 1} })
    original_payment = Payment.find(charge['payment_id'])

    if original_payment.refund_total.to_i + h['amount'].to_i > original_payment.gross_amount..to_i
      raise RuntimeError.new("Refund amount must be less than the net amount of the payment (for charge #{charge['id']})")
    end

    refund_data = {'amount' => h['amount'], 'charge' => charge['stripe_charge_id']}
    refund_data['reason'] = h['reason'] unless h['reason'].blank? # Stripe will error on blank reason field

    results = InsertRefunds.perform_stripe_refund(charge['nonprofit_id'], refund_data)

    Refund.transaction do 

      refund = Refund.create!({amount: h['amount'], 
        comment: h['comment'], 
        reason: h['reason'],
        stripe_refund_id: results[:stripe_refund].id,
        charge_id: charge['id']
      })

      refund.create_misc_refund_info(is_modern: true, stripe_application_fee_refund_id: results[:stripe_app_fee_refund]&.id)

      gross = -(h['amount'])
      fees = (results[:stripe_app_fee_refund] && results[:stripe_app_fee_refund].amount) || 0
      net = gross + fees
      
      # Create a corresponding./run  negative payment record
      payment = Payment.create!({
          gross_amount: gross,
          fee_total: fees,
          net_amount: net,
          kind: 'Refund',
          towards: original_payment.towards,
          date: refund.created_at,
          nonprofit_id: charge['nonprofit_id'],
          supporter_id: charge['supporter_id']
        })

      InsertActivities.for_refunds([payment.id])

      # Update the refund to have the above payment_id
      refund.payment = payment
      refund.save!
      
      # Update original payment to increment its refund_total for any future refund attempts
      original_payment.refund_total += h['amount'].to_i
      original_payment.save!
      # Send the refund receipts in a delayed job
    
      JobQueue.queue JobTypes::RefundCreatedJob, refund
    
      return {'payment' => payment.attributes, 'refund' => refund.attributes}
    end
  end

  def self.legacy_refund(charge, h)
    ParamValidation.new(charge, { 
      payment_id: {required: true, is_integer: true},
      stripe_charge_id: {required: true, format: /^(test_)?ch_.*$/},
      amount: {required: true, is_integer: true, min: 1},
      id: {required: true, is_integer: true},
      nonprofit_id: {required: true, is_integer: true},
      supporter_id: {required: true, is_integer: true}
    })
    ParamValidation.new(h, { amount: {required: true, is_integer: true, min: 1} })
    
    original_payment = Qx.select("*").from("payments").where(id: charge['payment_id']).execute.first
    raise ActiveRecord::RecordNotFound.new("Cannot find original payment for refund on charge #{charge['id']}") if original_payment.nil?

    if original_payment['refund_total'].to_i + h['amount'].to_i > original_payment['gross_amount'].to_i
      raise RuntimeError.new("Refund amount must be less than the net amount of the payment (for charge #{charge['id']})")
    end

    stripe_charge = Stripe::Charge.retrieve(charge['stripe_charge_id'])

    refund_post_data = {'amount' => h['amount'], 'refund_application_fee' => true, 'reverse_transfer' => true}
    refund_post_data['reason'] = h['reason'] unless h['reason'].blank? # Stripe will error on blank reason field
    stripe_refund = stripe_charge.refunds.create(refund_post_data)
    h['stripe_refund_id'] = stripe_refund.id

    refund_row = Qx.insert_into(:refunds).values(h.merge(charge_id: charge['id'])).timestamps.returning('*').execute.first

    gross = -(h['amount'])

    fees = (h['amount'] * -original_payment['fee_total'] / original_payment['gross_amount']).ceil
    net = gross + fees
    # Create a corresponding negative payment record
    payment_row = Qx.insert_into(:payments).values({
        gross_amount: gross,
        fee_total: fees,
        net_amount: net,
        kind: 'Refund',
        towards: original_payment['towards'],
        date: refund_row['created_at'],
        nonprofit_id: charge['nonprofit_id'],
        supporter_id: charge['supporter_id']
      })
      .timestamps
      .returning('*')
      .execute.first

    InsertActivities.for_refunds([payment_row['id']])

    # Update the refund to have the above payment_id
    refund_row = Qx.update(:refunds).set(payment_id: payment_row['id']).ts.where(id: refund_row['id']).returning('*').execute.first
    # Update original payment to increment its refund_total for any future refund attempts
    Qx.update(:payments).set("refund_total=refund_total + #{h['amount'].to_i}").ts.where(id: original_payment['id']).execute
    # Send the refund receipts in a delayed job
    Delayed::Job.enqueue JobTypes::DonorRefundNotificationJob.new(refund_row['id'])
    Delayed::Job.enqueue JobTypes::NonprofitRefundNotificationJob.new(refund_row['id'])
    return {'payment' => payment_row, 'refund' => refund_row}
  end

  # def self.calculate_application_fee_to_refund(nonprofit_id, stripe_refund, stripe_charge, stripe_application_fee)
  #   estimate_stripe_fee = Nonprofit.find(nonprofit_id).calculate_stripe_fee(amount: stripe_charge.amount, source: stripe_charge.source, at: Time.at(stripe_charge.created))
  #   our_fee = stripe_application_fee.amount - estimate_stripe_fee
  #   our_fee_left = our_fee - stripe_application_fee.amount_refunded
  #   if (our_fee_left <= 0)
  #     return 0
  #   end

  #   if (stripe_charge.refunded)
  #     #we refund all of our charges
  #     return our_fee_left
  #   else
  #     portion_of_charge_refunded = BigDecimal.new(stripe_refund.amount) / BigDecimal.new(stripe_charge.amount)
  #     amount_to_refund = (BigDecimal.new(our_fee) * portion_of_charge_refunded).floor
  #     if amount_to_refund >= our_fee_left
  #       return our_fee_left
  #     else
  #       return amount_to_refund
  #     end
  #   end
  # end

  def self.perform_stripe_refund(nonprofit_id, refund_data)
    refund_data = refund_data.merge({'reverse_transfer' => true, expand: ['charge']})
    stripe_refund = Stripe::Refund.create(refund_data, {stripe_version: '2019-09-09'})
    stripe_app_fee = Stripe::ApplicationFee.retrieve({id: stripe_refund.charge.application_fee}, {stripe_version: '2019-09-09'})
    fee_to_refund = Nonprofit.find(nonprofit_id).calculate_application_fee_refund(stripe_refund, stripe_refund.charge, stripe_app_fee)
    if fee_to_refund > 0
      app_fee_refund = Stripe::ApplicationFee.create_refund(stripe_refund.charge.application_fee, {amount: fee_to_refund}, {stripe_version: '2019-09-09'})
    end
    {stripe_refund: stripe_refund, stripe_app_fee_refund: app_fee_refund}
  end
end

