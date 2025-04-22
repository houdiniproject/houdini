FactoryBot.define do
  factory :stripe_account do
    stripe_account_id { "test_acct_1" }
    object { "{}" }

    trait :with_pending do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-pending")["data"]["object"] }
    end

    trait :with_temporarily_verified do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-temporarily_verified")["data"]["object"] }
    end

    trait :with_temporarily_verified_with_deadline do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-temporarily_verified-with-deadline")["data"]["object"] }
    end

    trait :with_verified do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-verified")["data"]["object"] }
    end

    trait :with_verified_and_bank_provided_with_active_but_empty_future_requirements do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-verified-and-bank-provided-with-active-but-empty-future_requirements")["data"]["object"] }
    end

    trait :with_verified_and_bank_provided_but_future_requirements do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-verified-and-bank-provided-but-future-requirements")["data"]["object"] }
    end

    trait :with_verified_and_bank_provided_but_future_requirements_pending do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-verified-and-bank-provided-but-future-requirements-pending")["data"]["object"] }
    end

    trait :with_unverified do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-unverified")["data"]["object"] }
    end

    trait :with_unverified_from_verified do
      object { StripeMockHelper.mock_webhook_event("account.updated.with-unverified-from-verified")["data"]["object"] }
    end

    trait :without_future_requirements do
      object { StripeMockHelper.mock_webhook_event("account.updated.without-future-requirements")["data"]["object"] }
    end
  end
end
