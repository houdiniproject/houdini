# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.string.com" }
    password { 'whocares' }
  end
end
