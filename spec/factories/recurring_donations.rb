# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :recurring_donation do
    factory :rd_with_dedication_designation do
      nonprofit { association :fv_poverty }
      start_date { Time.current }
      interval { 1 }
      time_unit { "month" }
    end
  end
end
