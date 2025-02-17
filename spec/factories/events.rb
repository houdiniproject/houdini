# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :event do
    name { "The event of Wonders" }
    start_datetime { DateTime.new(2025, 5, 11, 4, 5, 6) }
    end_datetime { DateTime.new(2025, 5, 11, 5, 1, 7) }
    address { "100 N Appleton St" }
    city { "Appleton" }
    state_code { "WI" }
    slug { "event-of-wonders" }
    nonprofit_id { 55352 }
    profile
  end

  factory :fv_poverty_fighting_event, class: "Event" do
    name { "Fighting Poverty 2021" }

    start_datetime { DateTime.new(2025, 5, 11, 4, 5, 6) }
    end_datetime { DateTime.new(2025, 5, 11, 5, 1, 7) }
    address { "100 N Appleton St" }
    city { "Appleton" }
    state_code { "WI" }
    slug { "fighting-poverty" }

    factory :fv_poverty_fighting_event_with_nonprofit_and_profile do
      nonprofit { create(:fv_poverty) }
      profile
    end
  end

  factory :event_base, class: "Event" do
    sequence(:name) { |i| "The event of Wonders #{i}" }
    start_datetime { DateTime.new(2025, 5, 11, 4, 5, 6) }
    end_datetime { DateTime.new(2025, 5, 11, 5, 1, 7) }
    address { "100 N Appleton St" }
    city { "Appleton" }
    state_code { "WI" }
    sequence(:slug) { |i| "event-of-wonders-#{i}" }
    nonprofit { association :nonprofit_base }
    profile
  end
end
