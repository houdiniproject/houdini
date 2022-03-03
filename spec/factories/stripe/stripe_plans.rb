
FactoryBot.define do
  factory :stripe_plan, aliases: [:stripe_plan_base], class: 'Stripe::Plan' do
    transient do 
      sequence(:id) {|i| "test_str_plan#{i}"}
    end
    currency {'usd'}
    amount { 0 }

    to_create do |instance, evaluator|
      StripeMockHelper.start
      plan = StripeMockHelper.stripe_helper.create_plan(**instance, id: evaluator.id)
      instance.update_attributes(**plan)
    end
  end
end