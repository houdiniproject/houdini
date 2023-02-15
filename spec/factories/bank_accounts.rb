# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :bank_account do
    name { Faker::Bank.name }
  end
end
