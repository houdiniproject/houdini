# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :source_token do
    token { SecureRandom.uuid }
    max_uses { 1 }
    expiration { 10.minutes.from_now }
    factory :source_token_for_supporter_for_fv_poverty do
      tokenizable { build(:card, holder: create(:supporter_with_fv_poverty)) }
    end

    factory :source_token_base do
      tokenizable { association :card_base }
      trait :with_stripe_card do
        tokenizable { association :card_base, :with_created_stripe_customer_and_card }
      end
    end
  end
end
