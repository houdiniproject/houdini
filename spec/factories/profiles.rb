FactoryBot.define do
  factory :profile do
    sequence(:email) {|n|"eric#{n}@fjelkt.com"}
    user
  end
end
