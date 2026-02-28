# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :role, aliases: [:role_base] do
    trait :as_nonprofit_admin do
      host { association :nonprofit_base }
      name { "nonprofit_admin" }
    end

    trait :as_nonprofit_associate do
      host { association :nonprofit_base }
      name { "nonprofit_associate" }
    end
  end
end
