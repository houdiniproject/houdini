FactoryBot.define do
  factory :stripe_customer, aliases: [:stripe_customer_base], class: "Stripe::Customer" do
    stripe_object_base
  end
end
