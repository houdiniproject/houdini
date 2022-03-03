
FactoryBot.define do
  factory :stripe_customer, aliases: [:stripe_customer_base], class: 'Stripe::Customer' do
  initialize_with { 
    new(**attributes)
  }
    currency {'usd'}
    to_create do |instance|
      StripeMockHelper.start
      instance.save
    end
  end
end