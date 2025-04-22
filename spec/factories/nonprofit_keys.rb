# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :nonprofit_key do
    nonprofit
    mailchimp_token { "a token" }
  end
end
