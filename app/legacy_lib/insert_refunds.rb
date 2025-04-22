# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module InsertRefunds
  # Refund a given charge, up to its net amount
  # params: amount, donation obj
  def self.with_stripe(charge, h)
    modern_refund(charge, h)
  end

  def self.modern_refund(charge, h)
    ParamValidation.new(charge, {
      payment_id: {required: true, is_integer: true},
      stripe_charge_id: {required: true, format: /^(test_)?ch_.*$/},
      amount: {required: true, is_integer: true, min: 1},
      id: {required: true, is_integer: true},
      nonprofit_id: {required: true, is_integer: true},
      supporter_id: {required: true, is_integer: true}
    })
    ParamValidation.new(h, {amount: {required: true, is_integer: true, min: 1}})
    original_payment = Payment.find(charge["payment_id"])

    if original_payment.refund_total.to_i + h["amount"].to_i > original_payment.gross_amount.to_i
      raise "Refund amount must be less than the net amount of the payment (for charge #{charge["id"]})"
    end

    refund_data = {"amount" => h["amount"], "charge" => charge["stripe_charge_id"]}
    refund_data["reason"] = h["reason"] unless h["reason"].blank? # Stripe will error on blank reason field

    results = InsertRefunds.perform_stripe_refund(nonprofit_id: charge["nonprofit_id"], refund_data: refund_data, charge_date: charge["created_at"])

    Refund.transaction do
      refund = Refund.create!({amount: h["amount"],
        comment: h["comment"],
        reason: h["reason"],
        stripe_refund_id: results[:stripe_refund].id,
        charge_id: charge["id"]})

      refund.create_misc_refund_info(is_modern: true, stripe_application_fee_refund_id: results[:stripe_app_fee_refund]&.id)

      gross = -h["amount"]
      fees = (results[:stripe_app_fee_refund] && results[:stripe_app_fee_refund].amount) || 0
      net = gross + fees

      # Create a corresponding./run  negative payment record
      payment = Payment.create!({
        gross_amount: gross,
        fee_total: fees,
        net_amount: net,
        kind: "Refund",
        towards: original_payment.towards,
        date: refund.created_at,
        nonprofit_id: charge["nonprofit_id"],
        supporter_id: charge["supporter_id"]
      })

      InsertActivities.for_refunds([payment.id])

      # Update the refund to have the above payment_id
      refund.payment = payment
      refund.save!

      # Update original payment to increment its refund_total for any future refund attempts
      original_payment.refund_total += h["amount"].to_i
      original_payment.save!
      # Send the refund receipts in a delayed job

      JobQueue.queue JobTypes::RefundCreatedJob, refund

      {"payment" => payment.attributes, "refund" => refund.attributes}
    end
  end

  # @param [Hash] opts
  # @option opts [Hash] :refund_data the data to pass to the Stripe::Refund#create method
  # @option opts [Integer] :nonprofit_id the nonprofit_id that the charge belongs to
  # @option opts [Time] :charge_date the time that the charge to be refunded occurred
  def self.perform_stripe_refund(opts = {})
    refund_data = opts[:refund_data].merge({"reverse_transfer" => true, :expand => ["charge"]})
    stripe_refund = Stripe::Refund.create(refund_data, {stripe_version: "2019-09-09"})
    stripe_app_fee = Stripe::ApplicationFee.retrieve({id: stripe_refund.charge.application_fee}, {stripe_version: "2019-09-09"})
    fee_to_refund = Nonprofit.find(opts[:nonprofit_id]).calculate_application_fee_refund(refund: stripe_refund, charge: stripe_refund.charge, application_fee: stripe_app_fee, charge_date: opts[:charge_date])
    if fee_to_refund > 0
      app_fee_refund = Stripe::ApplicationFee.create_refund(stripe_refund.charge.application_fee, {amount: fee_to_refund}, {stripe_version: "2019-09-09"})
    end
    {stripe_refund: stripe_refund, stripe_app_fee_refund: app_fee_refund}
  end
end
