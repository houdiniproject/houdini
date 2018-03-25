FactoryBot.define do
  factory :supporter do
    name "Fake Supporter Name"
    nonprofit

    trait :has_a_card do
      after(:create) {|supporter|
        create(:active_card_1, holder: supporter)
      }
    end
  end
end
