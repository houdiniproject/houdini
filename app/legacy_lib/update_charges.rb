# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateCharges
  def self.disburse_all_with_payments(payment_ids)
    Psql.execute(Qexpr.new.update(:charges, status: "disbursed").where("payment_id IN ($ids)", ids: payment_ids).returning("id", "status"))
  end

  def self.reverse_disburse_all_with_payments(payment_ids)
    Charge.where("payment_id IN (?)", payment_ids).update_all(status: "available")
  end
end
