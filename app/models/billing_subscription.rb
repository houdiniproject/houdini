# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingSubscription < ApplicationRecord

	#TODO
	# attr_accessible \
	# 	:nonprofit_id, :nonprofit,
	# 	:billing_plan_id, :billing_plan,
	# 	:stripe_subscription_id,
	# 	:status # trialing, active, past_due, canceled, or unpaid

	attr_accessor :stripe_plan_id, :manual
	belongs_to :nonprofit
	belongs_to :billing_plan

	validates :nonprofit, presence: true
	validates :billing_plan, presence: true

	def as_json(options={})
		h = super(options)
		h[:plan_name] = self.billing_plan.name
		h[:plan_amount] = self.billing_plan.amount / 100
		h
	end

	def self.create_with_stripe(np, params)
		bp = BillingPlan.find_by_stripe_plan_id params[:stripe_plan_id]
		h =  ConstructBillingSubscription.with_stripe np, bp
		return np.create_billing_subscription h
	end

end

