# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :custom_field_join do
    custom_field_definition_id { 1 }
    supporter_id { 4 }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    value { "value" }

    trait :value_from_id do
      after(:create) do |cfj|
        cfj.value = "Value#{cfj.id}"
      end
    end
  end
end
