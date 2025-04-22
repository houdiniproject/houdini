# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
