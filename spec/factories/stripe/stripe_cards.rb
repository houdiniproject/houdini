# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :stripe_card, aliases: [:stripe_card_base], class: 'Stripe::Card' do
    transient do 
      stripe_customer { association  :stripe_customer_base }
      stripe_token { association :stripe_token_base}
      currency {'usd'}
    end
  
    to_create do |instance, evaluator|
      StripeMockHelper.start
      source = Stripe::Customer.create_source(evaluator.stripe_customer.id, {tok: evaluator.stripe_token.id})
      instance.update_attributes(source)
    end
  end
end