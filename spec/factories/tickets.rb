FactoryBot.define do
  factory :ticket do

    trait :has_event do
      event
    end

    trait :has_card do
      card
    end
  end
end
