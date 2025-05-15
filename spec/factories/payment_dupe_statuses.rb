FactoryBot.define do
  factory :payment_dupe_status do
    payment_id { 1 }
    matched { false }
  end
end
