# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateCharges
  def self.disburse_all_with_payments(payment_ids)
    Psql.execute(Qexpr.new.update(:charges, status: "disbursed").where("payment_id IN ($ids)", ids: payment_ids).returning("id", "status"))
  end

  def self.reverse_disburse_all_with_payments(payment_ids)
    Charge.where("payment_id IN (?)", payment_ids).update_all(status: "available")
  end
end
