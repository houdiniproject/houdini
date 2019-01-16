# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :custom_field_join do
    custom_field_master_id { 1 }
    supporter_id { 4 }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    value { 'value' }

    trait :value_from_id do
      after(:create) do |cfj|
        cfj.value = "Value#{cfj.id}"
      end
    end

  end
end
