FactoryBot.define do
  factory :dispute_transaction do
    dispute nil
    payment nil
    amount 1
    disbursed false
  end
end
