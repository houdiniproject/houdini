FactoryBot.define do
  factory :manual_balance_adjustment do
    fee_total { -100 }
    gross_amount { 0 }

    trait :with_entity_and_payment do
      entity { create(:charge_base) }
    end
  end
end
