# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :user, aliases: [:user_base] do
    sequence(:email) { |i| "user#{i}@example.string.com" }
    password { "whocares" }

    factory :confirmed_user do
      confirmed_at { Time.current }
    end
  end
end
