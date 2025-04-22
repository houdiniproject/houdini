# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  trait :with_offline_payment do
    offsite_payment {
      association :offsite_payment_base,
        nonprofit: nonprofit,
        supporter: supporter,
        gross_amount: gross_amount,
        payment: @instance
    }
  end

  trait :with_offline_donation do
    with_offline_payment
    donation { build(:donation_base, supporter: supporter, payments: [@instance]) }
  end

  factory :payment, aliases: [:payment_base, :legacy_payment_base] do
    supporter { association :supporter_base }
    nonprofit { supporter.nonprofit }
    gross_amount { 333 }
    fee_total { 0 }
    net_amount { gross_amount + fee_total }
  end

  factory :payment_generator_with_id, class: "Payment" do
    transient do
      amount { Random.rand(100..5099) }
    end

    sequence(:id)

    gross_amount { amount }
    supporter
    date { Faker::Time.between(from: Time.current.beginning_of_year, to: Time.current.end_of_year) }

    before(:create) do |payment|
      payment.id = nil if payment.id
    end

    factory :donation_payment_generator do
      donation { association :donation, amount: amount, supporter: supporter, nonprofit: nonprofit, created_at: date }
    end

    factory :refund_payment_generator do
      refund { association :refund_base, amount: amount * -1, created_at: date }
      gross_amount { amount * -1 }
    end

    factory :dispute_payment_generator do
      dispute_transaction { association :dispute_transaction_base, created_at: date }
    end

    factory :dispute_reversal_payment_generator do
      dispute_transaction { association :dispute_transaction_base, created_at: date }
      gross_amount { amount * -1 }
    end
  end

  factory :fv_poverty_payment, class: "Payment" do
    donation { build(:fv_poverty_donation, nonprofit: nonprofit, supporter: supporter) }
    gross_amount { 333 }
    net_amount { 333 }
    nonprofit { association :fv_poverty }
    supporter { build(:supporter_with_fv_poverty, nonprofit: nonprofit) }

    trait :anonymous_through_donation do
      donation { build(:fv_poverty_donation, nonprofit: nonprofit, supporter: supporter, anonymous: true) }
    end

    trait :anonymous_through_supporter do
      supporter { build(:supporter_with_fv_poverty, nonprofit: nonprofit, anonymous: true) }
    end
  end
end
