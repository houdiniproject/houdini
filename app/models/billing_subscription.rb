# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingSubscription < ApplicationRecord
  attr_accessible \
    :nonprofit_id, :nonprofit,
    :billing_plan_id, :billing_plan,
    :stripe_subscription_id,
    :status # trialing, active, past_due, canceled, or unpaid

  attr_accessor :stripe_plan_id, :manual
  belongs_to :nonprofit
  belongs_to :billing_plan

  validates :nonprofit, presence: true
  validates :billing_plan, presence: true

  def as_json(options = {})
    h = super
    h[:plan_name] = billing_plan.name
    h[:plan_amount] = billing_plan.amount / 100
    h
  end

  def stripe_subscription
    Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  concerning :PathCaching do
    included do
      after_save do
        nonprofit.clear_cache
        true
      end
    end

    class_methods do
      def clear_cache(np)
        Rails.cache.delete(BillingSubscription.create_cache_key(np))
      end

      def find_via_cached_np_id(np)
        np = np.id if np.is_a? Nonprofit
        key = BillingSubscription.create_cache_key(np)
        Rails.cache.fetch(key, expires_in: 4.hours) do
          Qx.fetch(:billing_subscriptions, {nonprofit_id: np}).last
        end
      end

      def create_cache_key(np)
        np = np.id if np.is_a? Nonprofit
        "billing_subscription_nonprofit_id_#{np}"
      end
    end
  end
end
