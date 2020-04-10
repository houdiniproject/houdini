# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingPlan < ActiveRecord::Base
	Names = ['Starter', 'Fundraising', 'Supporter Management']
	DefaultAmounts = [0, 9900, 29900] # in pennies

	attr_accessible \
		:name, #str: readable name
		:tier, #int: 0-4 (0: Free, 1: Fundraising, 2: Supporter Management)
		:amount, #int (cents)
		:stripe_plan_id, #str (matches plan ID in Stripe) Not needed if it's not a paying subscription
		:interval, #str ('monthly', 'annual')
		:percentage_fee # 0.038

	has_many :billing_subscriptions

	validates :name, :presence => true
	validates :amount, :presence => true

	def self.clear_cache(np)
		Rails.cache.delete(BillingPlan.create_cache_key(np))
	end

	def self.find_via_cached_np_id(np)
		np = Nonprofit.find_via_cached_id(np.id) unless np.is_a? Nonprofit
		key = BillingPlan.create_cache_key(np)
		Rails.cache.fetch(key, expires_in: 4.hours) do
			np.billing_plan
		end
	  end

	def self.create_cache_key(np)
		np = np.id if np.is_a? Nonprofit
		"billing_plan_nonprofit_id_#{np}"
	end
end
