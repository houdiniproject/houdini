# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :donation do
    factory :donation_with_dedication_designation do
      dedication {
        {
          contact: {
            email: "email@ema.com"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        }
      }
      designation { "designated for soup kitchen" }

      nonprofit { association :fv_poverty }

      supporter { association :supporter }
      amount { 500 }
    end
  end
end
