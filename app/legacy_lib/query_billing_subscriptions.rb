# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'
require 'active_support/core_ext'

module QueryBillingSubscriptions

  def self.plan_tier(np_id)
    sub = BillingSubscription::find_via_cached_np_id(np_id)
    # hard coding to 2 because that's the all in plan tier and that's all we have.
    return 2
  end
end

