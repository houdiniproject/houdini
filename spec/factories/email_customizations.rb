# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :email_customization do
    name { "name" }
    contents { "email customization contents" }
    nonprofit { association :nonprofit_base }
  end
end
