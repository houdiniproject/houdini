FactoryBot.define do
  factory :stripe_account do
    currently_due []
    eventually_due []
    past_due []
    pending_verification []
    stripe_account_id "test_acct_1"
    object "{}"
  end
end
