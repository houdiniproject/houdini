# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :billing_plan do
    amount { 0 }
    name { 'Default Plan' }
    trait :default do

    end
  end
end
