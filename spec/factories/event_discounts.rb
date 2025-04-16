# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :event_discount, aliases: [:event_discount_base] do
    event { association :event_base }

    sequence(:name) { |i| "Discount tier #{i}" }

    code { Faker::Emotion.adjective + "-" + Faker::Emotion.noun }
    percent { Faker::Number.between(from: 1, to: 99) }
  end
end
