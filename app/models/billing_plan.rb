# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingPlan < ApplicationRecord
  Names = ["Starter", "Fundraising", "Supporter Management"]

  attr_accessible \
    :name, # str: readable name
    :amount, # int (cents)
    :stripe_plan_id, # str (matches plan ID in Stripe) Not needed if it's not a paying subscription
    :interval, # str ('monthly', 'annual')
    :percentage_fee, # 0.038
    :flat_fee

  has_many :billing_subscriptions

  validates :name, presence: true
  validates :amount, presence: true
  validates :percentage_fee, presence: true

  validates :amount, numericality: {greater_than_or_equal_to: 0}
  validates :percentage_fee, numericality: {less_than: 1, greater_than_or_equal_to: 0}

  validates :flat_fee, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  concerning :PathCaching do
    class_methods do
      def clear_cache(np)
        Rails.cache.delete(BillingPlan.create_cache_key(np))
      end

      def find_via_cached_np_id(np)
        np = Nonprofit.find_via_cached_id(np.id) unless np.is_a? Nonprofit
        key = BillingPlan.create_cache_key(np)
        Rails.cache.fetch(key, expires_in: 4.hours) do
          np.billing_plan
        end
      end

      def create_cache_key(np)
        np = np.id if np.is_a? Nonprofit
        "billing_plan_nonprofit_id_#{np}"
      end
    end
  end
end
