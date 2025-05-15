# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :email_setting do
    user { association :user_as_nonprofit_associate, nonprofit: nonprofit }
    nonprofit { association :base_nonprofit }
  end
end
