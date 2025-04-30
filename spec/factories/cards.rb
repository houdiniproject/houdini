# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :card, aliases: [:active_card_1, :active_card_2, :card_base] do
    name { "card 1" }
    factory :inactive_card do
      inactive { true }
    end
    trait :with_created_stripe_customer_and_card do
      transient do
        stripe_card { association :stripe_card_base }
      end

      stripe_card_id { stripe_card.id }
      stripe_customer_id { stripe_card.customer }
    end

    trait :with_supporter do
      holder { association :supporter_base }
    end
  end
end
