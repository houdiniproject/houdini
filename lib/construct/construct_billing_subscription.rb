# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'stripe'
require 'active_support/core_ext'

module ConstructBillingSubscription

	def self.with_stripe(np, billing_plan)
		raise ArgumentError.new("Billing plan not found") if billing_plan.nil?
		trial_end = QueryBillingSubscriptions.currently_in_trial?(np.id) ? (np.created_at + 15.days).to_i : nil
		customer = Stripe::Customer.retrieve np.active_card.stripe_customer_id
		stripe_subscription = customer.subscriptions.create({
			plan: billing_plan.stripe_plan_id,
			trial_end: trial_end
		})
		return {
			billing_plan_id: billing_plan.id,
			stripe_subscription_id: stripe_subscription.id,
			status: stripe_subscription.status
		}
	end

end
