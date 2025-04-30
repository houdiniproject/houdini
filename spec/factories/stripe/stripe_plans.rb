FactoryBot.define do
  factory :stripe_plan, aliases: [:stripe_plan_base], class: "Stripe::Plan" do
    stripe_object_base

    transient do
      sequence(:id) { |i| "test_str_plan#{i}" }
      product { association :stripe_product }
    end
    currency { "usd" }
    amount { 0 }

    to_create do |instance, evaluator|
      plan = StripeMockHelper.stripe_helper.create_plan(**instance, id: evaluator.id, product: evaluator.product.id)
      instance.update_attributes(plan)
    end
  end
end
