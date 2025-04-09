# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :stripe_product, aliases: [:stripe_product_base], class: 'Stripe::Product' do

    stripe_object_base

    transient do 
      sequence(:id) {|i| "test_str_product#{i}"}
    end
    name { id }

    to_create do |instance, evaluator|
      product = StripeMockHelper.stripe_helper.create_product(**instance, id: evaluator.id)
      instance.update_attributes(product)
    end
  end
end