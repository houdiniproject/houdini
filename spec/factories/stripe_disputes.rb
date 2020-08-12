FactoryBot.define do
  factory :stripe_dispute do
    stripe_dispute_id "dispute_test_id"
    stripe_charge_id "charge_test_id"
  end
end
