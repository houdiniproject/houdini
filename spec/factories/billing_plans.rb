# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :billing_plan do
    amount {0}
    name {'Default Plan'}
    trait :default do

    end
  end

  factory :billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat, parent: :billing_plan do 
    percentage_fee { 0.025 }
    flat_fee { 5 }
  end

  factory :billing_plan_percentage_fee_of_1_8_percent, parent: :billing_plan do 
    percentage_fee { 0.018 }
  end

  factory :billing_plan_percentage_fee_of_3_8_percent, parent: :billing_plan do 
    percentage_fee { 0.018 }
  end
end
