# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "webmock/rspec"

describe "events factory" do
  let!(:stub_request_to_google_maps) { stub_request(:get, %r{https://maps.googleapis.com/maps/api/geocode/json.*}) }

  it "defaults to return nil for geocode" do
    create(:event_base)
    expect(stub_request_to_google_maps).to have_not_been_made
  end

  it "contacts Google Maps api when perform_geocode is set" do
    create(:event_base, perform_geocode: true)

    expect(stub_request_to_google_maps).to have_been_made
  end
end
