# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateNonprofit
  # Update charges from pending to available if the nonprofit's balance on stripe can accommodate them
  # First, get net balance on Stripe, then get net balance on CC
  # Take the difference of those two, and mark as many oldest pending charges as 'available' as are less than or equal to that difference
  def self.mark_available_charges(npo_id)
    stripe_account_id = Qx.select("stripe_account_id").from(:nonprofits).where(id: npo_id).ex.first["stripe_account_id"]
    stripe_net_balance = Stripe::Balance.retrieve(stripe_account: stripe_account_id).available.first.amount
    cc_net_balance = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(npo_id))["net_amount"]

    pending_payments = Qx.select("payments.net_amount", "charges.id AS charge_id")
      .from(:payments)
      .where("charges.status='pending'")
      .and_where("payments.nonprofit_id=$id", id: npo_id)
      .join("charges", "charges.payment_id=payments.id")
      .order_by("payments.date ASC")
      .execute

    return if pending_payments.empty?

    remaining_balance = stripe_net_balance - cc_net_balance
    charge_ids = pending_payments.take_while do |payment|
      if payment["net_amount"] <= remaining_balance
        remaining_balance -= payment["net_amount"]
        true
      end
    end.map { |h| h["charge_id"] }

    Qx.update(:charges).set(status: "available").where("id IN ($ids)", ids: charge_ids).execute if charge_ids.any?
  end
end
