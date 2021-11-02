FactoryBot.define do
  factory :stripe_account do
    stripe_account_id "test_acct_1"
    object "{}"

    trait :with_pending do 
      object { StripeMock.mock_webhook_event('account.updated.with-pending')['data']['object']}
    end

    trait :with_temporarily_verified do 
      object { StripeMock.mock_webhook_event('account.updated.with-temporarily_verified')['data']['object']}
    end
    
    trait :with_temporarily_verified_with_deadline do
      object { StripeMock.mock_webhook_event('account.updated.with-temporarily_verified-with-deadline')['data']['object']}
    end

    trait :with_verified do
      object { StripeMock.mock_webhook_event('account.updated.with-verified')['data']['object']}
    end

    trait :with_unverified do
      object { StripeMock.mock_webhook_event('account.updated.with-unverified')['data']['object']}
    end

    trait :with_unverified_from_verified do
      object { StripeMock.mock_webhook_event('account.updated.with-unverified-from-verified')['data']['object']}
    end
  end
end
