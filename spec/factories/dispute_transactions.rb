FactoryBot.define do
  factory :dispute_transaction, aliases: [:dispute_transaction_base] do
    disbursed { false }

    trait :from_donation do
      dispute { build(:dispute, charge: build(:charge_base, payment: build(:payment, donation: build(:donation)))) }
    end

    trait :not_from_donation do
      dispute { build(:dispute, charge: build(:charge_base, payment: build(:payment))) }
    end
  end
end
