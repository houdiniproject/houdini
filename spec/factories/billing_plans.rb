# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :billing_plan do
    amount { 0 }
    name { "Default Plan" }
    trait :default do
    end
  end
end
