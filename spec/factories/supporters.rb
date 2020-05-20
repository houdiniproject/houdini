# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :supporter do
    name { 'Fake Supporter Name' }
    nonprofit_id { 55352 }
    trait :has_a_card do
      after(:create) do |supporter|
        create(:active_card_1, holder: supporter)
      end
    end
  end
end
