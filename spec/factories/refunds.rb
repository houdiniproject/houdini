# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :refund, aliases: [:refund_base] do
    trait :from_donation do
      charge { build(:charge_base, payment: build(:payment, donation: build(:donation))) }
    end

    trait :not_from_donation do
      charge { build(:charge_base, payment: build(:payment)) }
    end
  end
end
