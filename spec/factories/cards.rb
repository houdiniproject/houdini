# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :card do
    factory :active_card_1 do
      name { "card 1" }
    end
    factory :active_card_2 do
      name { "card 1" }
    end
    factory :inactive_card do
      name { "card 1" }
      inactive { true }
    end
  end
end
