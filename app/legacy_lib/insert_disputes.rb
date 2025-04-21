# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertDisputes
  # A new dispute takes a charge id and dispute id and creates:
  # A dispute row with the charge gross amount and the dispute id
  # A payment row negative gross and net, just like a refund, but with kind "Dispute"
  def self.create_record(stripe_charge_id, stripe_dispute_id)
    # Find the existing charge
    ch = Qx.select("*").from("charges").where("stripe_charge_id=$id", id: stripe_charge_id).ex.first
    raise ArgumentError, "Charge not found" if ch.nil?

    result = {}
    now = Time.current

    result[:payment] = Psql.execute(
      Qexpr.new.insert(:payments, [{
        gross_amount: -ch["amount"],
        fee_total: 0,
        net_amount: -ch["amount"],
        kind: "Dispute",
        refund_total: 0,
        nonprofit_id: ch["nonprofit_id"],
        supporter_id: ch["supporter_id"],
        donation_id: ch["donation_id"],
        date: now
      }]).returning("*")
    ).first

    # Create a dispute record
    result[:dispute] = Psql.execute(
      Qexpr.new.insert(:disputes, [{
        gross_amount: ch["amount"],
        status: :needs_response,
        charge_id: ch["id"],
        reason: :unrecognized,
        payment_id: result[:payment]["id"],
        stripe_dispute_id: stripe_dispute_id
      }]).returning("*")
    ).first

    # Prevent refunds from being able to happen on the payment
    Qx.update(:payments).set(refund_total: ch["amount"]).where(id: ch["payment_id"]).ex

    # Insert an activity record
    InsertActivities.for_disputes([result[:payment]["id"]])

    result
  end
end
