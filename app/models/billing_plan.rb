# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingPlan < ApplicationRecord
	Names = ['Starter', 'Fundraising', 'Supporter Management']
	DefaultAmounts = [0, 9900, 29900] # in pennies

	#TODO
	# attr_accessible \
	# 	:name, #str: readable name
	# 	:tier, #int: 0-4 (0: Free, 1: Fundraising, 2: Supporter Management)
	# 	:amount, #int (cents)
	# 	:stripe_plan_id, #str (matches plan ID in Stripe) Not needed if it's not a paying subscription
	# 	:interval, #str ('monthly', 'annual')
	# 	:percentage_fee # 0.038

	has_many :billing_subscriptions

	validates :name, :presence => true
	validates :amount, :presence => true
end
