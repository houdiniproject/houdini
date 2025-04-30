# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdatePayouts
  def self.reverse_with_stripe(payout_id, status, failure_message)
    ParamValidation.new({payout_id: payout_id, status: status, failure_message: failure_message}, {
      payout_id: {required: true, is_integer: true},
      status: {included_in: ["pending", "paid", "canceled", "failed"], required: true},
      failure_message: {not_blank: true, required: true}
    })
    payout = Payout.where("id = ?", payout_id).first
    unless payout
      raise ParamValidation::ValidationError.new("No payout with id number: #{payout_id} ", [{key: :payout_id}])
    end

    payment_ids = payout.payments.select("payments.id").map { |i| i.id }.to_a
    if payment_ids.count < 1
      raise ArgumentError.new("No payments are available to reverse.")
    end
    Time.current

    Psql.transaction do
      # Retrieve all payments with available charges and undisbursed refunds
      # Mark all the above payments as disbursed
      UpdateCharges.reverse_disburse_all_with_payments(payment_ids)
      # Mark all the above refunds as disbursed

      UpdateRefunds.reverse_disburse_all_with_payments(payment_ids)
      # Mark all disputes as lost_and_paid
      UpdateDisputes.reverse_disburse_all_with_payments(payment_ids)
      # Get gross total, total fees, net total, and total count
      # Create the payout record (whether it succeeded on Stripe or not)
      payout.status = status
      payout.failure_message = failure_message
      payout.save!

      # NonprofitMailer.delay.pending_payout_notification(payout['id'].to_i)
      payout
    end
  end
end
