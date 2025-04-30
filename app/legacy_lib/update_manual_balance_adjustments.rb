# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateManualBalanceAdjustments
  def self.disburse_all_with_payments(payment_ids)
    ManualBalanceAdjustment.where("payment_id IN (?)", payment_ids).update_all(
      disbursed: true,
      updated_at: Time.current
    )
  end
end
