# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :billing_subscription, aliases: [:billing_subscription_base] do
    nonprofit { association :nonprofit_base }
    billing_plan { association :billing_plan_base }
    trait :with_associated_stripe_subscription do
      transient do
        stripe_subscription { association :stripe_subscription_base, stripe_customer: stripe_customer }
        stripe_customer { association :stripe_customer_base }
      end
      billing_plan { association :billing_plan_base, :with_associated_stripe_plan }
      stripe_subscription_id { stripe_subscription.id }
    end
  end
end
