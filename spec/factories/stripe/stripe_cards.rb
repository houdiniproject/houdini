# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :stripe_card, aliases: [:stripe_card_base], class: "Stripe::Card" do
    stripe_object_base

    transient do
      stripe_customer { association :stripe_customer_base }
      stripe_token { association :stripe_token_base }
      stripe_token_id { stripe_token.id }
      stripe_customer_id { stripe_customer.id }
      currency { "usd" }
    end

    to_create do |instance, evaluator|
      source = Stripe::Customer.create_source(evaluator.stripe_customer_id, {source: evaluator.stripe_token_id})
      instance.update_attributes(source)
    end
  end
end
