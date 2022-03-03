
FactoryBot.define do
  factory :stripe_subscription, aliases: [:stripe_subscription_base], class: 'Stripe::Subscription' do
    transient do
      stripe_customer { association :stripe_customer_base}
      stripe_plan {association :stripe_plan_base} 
    end
    plan { stripe_plan.id }
    customer { stripe_customer.id}

    to_create do |instance|
      StripeMockHelper.start
      instance.save
    end
  end
end