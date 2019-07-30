# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :nonprofit do
    name { 'spec_nonprofit_full' }
    city { 'Albuquerque' }
    state_code { 'NM' }
    zip_code { 55_555 }
    email { 'example@email.com' }
    slug { 'sluggy-sluggo' }

    factory :nonprofit_with_cards do
      after(:create) do |nonprofit, _evaluator|
        create(:active_card_1, holder: nonprofit)
        create(:active_card_2, holder: nonprofit)
        create(:inactive_card, holder: nonprofit)
      end
    end

    after(:create) do |nonprofit, _evaluator|
      create(:supporter, nonprofit: nonprofit)
    end
  end
end
