# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe AddressHelper, type: :helper do
  it "#google_maps_url returns the proper value for event" do
    event = build(:event)
    expect(helper.google_maps_url(event)).to eq "https://maps.google.com/?q=100+N+Appleton+St%2C+Appleton+WI"
  end
end
