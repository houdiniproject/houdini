# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :ticket do
    trait :has_event do
      event
    end

    trait :has_card do
      card
    end
  end

  factory :ticket_base, class: "Ticket" do
    supporter { association :supporter, email: Faker::Internet.email, nonprofit: association(:nonprofit_base, email: Faker::Internet.email) }
    event { association :event_base, nonprofit: supporter.nonprofit }
  end
end
