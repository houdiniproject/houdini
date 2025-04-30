# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateRefunds
  def self.disburse_all_with_payments(payment_ids)
    Qx.update(:refunds)
      .set(disbursed: true)
      .timestamps
      .where("payment_id IN ($ids)", ids: payment_ids)
      .returning("*")
      .execute
  end

  def self.reverse_disburse_all_with_payments(payment_ids)
    Refund.where("payment_id IN (?)", payment_ids).update_all(disbursed: false)
  end
end
