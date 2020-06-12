# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'stripe'
require 'active_support/core_ext'

module ConstructBillingSubscription
  def self.with_stripe(np, billing_plan)
    raise ArgumentError, 'Billing plan not found' if billing_plan.nil?

    customer = Stripe::Customer.retrieve np.active_card.stripe_customer_id
    stripe_subscription = customer.subscriptions.create(
      plan: billing_plan.stripe_plan_id
    )
    {
      billing_plan_id: billing_plan.id,
      stripe_subscription_id: stripe_subscription.id,
      status: stripe_subscription.status
    }
  end
end
