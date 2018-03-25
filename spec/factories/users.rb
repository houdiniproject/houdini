FactoryBot.define do
  factory :user do
    sequence(:email) {|i| "user#{i}@example.string.com"}
    password "whocares"
  end
end
