# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateNonprofit
  # See the stripe docs for reference: => https://stripe.com/docs/connect/identity-verification
  def self.verify_identity(np_id, legal_entity, tos = nil)
    np = Qx.select("*").from(:nonprofits).where(id: np_id).execute.first
    legal_entity[:address][:country] = "US" if legal_entity[:address]
    acct = FetchStripeAccount.with_account_id(np["stripe_account_id"])
    acct.legal_entity.phone_number = acct.support_phone = legal_entity[:phone_number] if legal_entity[:phone_number]
    acct.legal_entity.business_tax_id = legal_entity[:business_tax_id] if legal_entity[:business_tax_id]
    acct.legal_entity.address = legal_entity[:address] if legal_entity[:address]
    acct.legal_entity.first_name = legal_entity[:first_name] if legal_entity[:first_name]
    acct.legal_entity.last_name = legal_entity[:last_name] if legal_entity[:last_name]
    acct.legal_entity.dob = legal_entity[:dob] if legal_entity[:dob]
    acct.legal_entity.ssn_last_4 = legal_entity[:ssn_last_4] if legal_entity[:ssn_last_4]
    acct.legal_entity.personal_id_number = legal_entity[:personal_id_number] if legal_entity[:personal_id_number]
    acct.legal_entity.type = "company"
    acct.legal_entity.business_name = np["name"]
    acct.tos_acceptance = tos if tos
    acct.save

    # Might as well update the nonprofit info
    if legal_entity[:address] && legal_entity[:business_tax_id]
      Qx.update(:nonprofits).set(
        address: legal_entity[:address][:line1],
        city: legal_entity[:address][:city],
        state_code: legal_entity[:address][:state],
        zip_code: legal_entity[:address][:postal_code],
        ein: legal_entity[:business_tax_id],
        verification_status: "pending",
        phone: legal_entity[:phone_number]
      )
        .where(id: np_id)
        .returning("*")
        .execute.first
    else
      Qx.update(:nonprofits).set(verification_status: "pending").where(id: np_id).returning("*").first
    end
  end

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
