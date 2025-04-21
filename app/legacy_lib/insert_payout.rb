# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# Create a new payout

module InsertPayout
  # Pass in the following inside the data hash:
  # - stripe_account_id
  # - email
  # - user_ip
  # - bank_name
  # options hash can have a :date (before date) for only paying out funds before a certain date (useful for only disbursing the prev month)
  def self.with_stripe(np_id, data, options = {})
    bigger_data = (data || {}).merge(np_id: np_id)
    ParamValidation.new(bigger_data,
      np_id: {required: true, is_integer: true},
      stripe_account_id: {not_blank: true, required: true},
      email: {not_blank: true, required: true},
      user_ip: {not_blank: true, required: true},
      bank_name: {not_blank: true, required: true})
    options ||= {}
    entities = RetrieveActiveRecordItems.retrieve_from_keys(bigger_data, Nonprofit => :np_id)
    payment_ids = QueryPayments.ids_for_payout(np_id, options)
    if payment_ids.count < 1
      raise ArgumentError, "No payments are available for disbursal on this account."
    end

    totals = QueryPayments.get_payout_totals(payment_ids)
    nonprofit_currency = entities[:np_id].currency
    Time.current
    payout = nil
    begin
      stripe_transfer = StripeUtils.create_transfer(totals["net_amount"], data[:stripe_account_id], nonprofit_currency)
      Psql.transaction do
        # Create the Transfer on Stripe

        # Retrieve all payments with available charges and undisbursed refunds
        # Mark all the above payments as disbursed
        UpdateCharges.disburse_all_with_payments(payment_ids)
        # Mark all the above refunds as disbursed
        UpdateRefunds.disburse_all_with_payments(payment_ids)
        # Mark all disputes as lost_and_paid
        UpdateDisputes.disburse_all_with_payments(payment_ids)
        # Get gross total, total fees, net total, and total count
        # Create the payout record (whether it succeeded on Stripe or not)
        payout = Psql.execute(
          Qexpr.new.insert(:payouts, [{
            net_amount: totals["net_amount"],
            nonprofit_id: np_id,
            failure_message: stripe_transfer["failure_message"],
            status: stripe_transfer.status,
            fee_total: totals["fee_total"],
            gross_amount: totals["gross_amount"],
            email: data[:email],
            count: totals["count"],
            stripe_transfer_id: stripe_transfer.id,
            user_ip: data[:user_ip],
            ach_fee: 0,
            bank_name: data[:bank_name]
          }])
          .returning("id", "net_amount", "nonprofit_id", "created_at", "updated_at", "status", "fee_total", "gross_amount", "email", "count", "stripe_transfer_id", "user_ip", "ach_fee", "bank_name")
        ).first
        # Create PaymentPayout records linking all the payments to the payout
        Psql.execute(Qexpr.new.insert("payment_payouts", payment_ids.map { |id| {payment_id: id.to_i} }, common_data: {payout_id: payout["id"].to_i}))
        PayoutPendingJob.perform_later(Payout.find(payout["id"].to_i))
      end
      payout
    rescue Stripe::StripeError => e
      Psql.execute(
        Qexpr.new.insert(:payouts, [{
          net_amount: totals["net_amount"],
          nonprofit_id: np_id,
          failure_message: e.message,
          status: "failed",
          fee_total: totals["fee_total"],
          gross_amount: totals["gross_amount"],
          email: data[:email],
          count: totals["count"],
          stripe_transfer_id: nil,
          user_ip: data[:user_ip],
          ach_fee: 0,
          bank_name: data[:bank_name]
        }])
            .returning("id", "net_amount", "nonprofit_id", "created_at", "updated_at", "status", "fee_total", "gross_amount", "email", "count", "stripe_transfer_id", "user_ip", "ach_fee", "bank_name")
      ).first
    end
  end
end
