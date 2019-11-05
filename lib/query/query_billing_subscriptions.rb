# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'
require 'active_support/core_ext'

module QueryBillingSubscriptions
  def self.plan_tier(np_id)
    sub = Qx.fetch(:billing_subscriptions, nonprofit_id: np_id).last
    return 2 if sub && sub['status'] != 'inactive'

    0
  end
end
