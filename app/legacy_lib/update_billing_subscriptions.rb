# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateBillingSubscriptions

  def self.activate_from_trial(np_id)
    Qx.update(:billing_subscriptions)
      .set(status: 'active')
      .timestamps
      .where('nonprofit_id=$id', id: np_id)
      .execute
  end
end
