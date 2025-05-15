# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :event do
    name { "The event of Wonders" }
    start_datetime { DateTime.new(2025, 5, 11, 4, 5, 6) }
    end_datetime { DateTime.new(2025, 5, 11, 5, 1, 7) }
    address { "100 N Appleton St" }
    city { "Appleton" }
    state_code { "WI" }
    slug { "event-of-wonders" }
    nonprofit
    profile
  end

  factory :event_base, class: "Event" do
    transient do
      perform_geocode { false }
    end
    sequence(:name) { |i| "The event of Wonders #{i}" }
    start_datetime { 2.days.from_now }
    end_datetime { 2.days.from_now + 3.hours }
    address { "100 N Appleton St" }
    city { "Appleton" }
    state_code { "WI" }
    sequence(:slug) { |i| "event-of-wonders-#{i}" }
    nonprofit { association :nonprofit_base }
    profile

    before(:create) do |event, context|
      allow(event).to receive(:geocode).and_return(nil) unless context.perform_geocode
    end
  end
end
