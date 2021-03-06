# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :event do
    name { 'The event of Wonders' }
    start_datetime { DateTime.new(2025, 5, 11, 4, 5, 6) }
    end_datetime { DateTime.new(2025, 5, 11, 5, 1, 7) }
    address { '100 N Appleton St' }
    city { 'Appleton' }
    state_code { 'WI' }
    slug { 'event-of-wonders' }
    nonprofit_id { 55352 }
    profile
  end
end
