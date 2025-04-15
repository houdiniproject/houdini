# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "Event discounts", type: :routing do
  let(:event) { create(:event_base) }
  let(:nonprofit) { event.nonprofit }

  let(:event_discount) { create(:event_discount_base, event: event) }

  before(:each) do
    # we don't care about geocoding
    allow_any_instance_of(Event).to receive(:geocode).and_return(nil)

    # this makes sure that our routes have a default host which is what they need for testing
    allow(Rails.application.routes).to receive(:default_url_options).and_return(ApplicationMailer.default_url_options)
  end

  it "create" do
    expect(post: nonprofit_event_event_discounts_path(nonprofit_id: nonprofit, event_id: event.id)).to route_to(
      controller: "event_discounts",
      action: "create",
      nonprofit_id: nonprofit.id.to_s,
      event_id: event.id.to_s
    )
  end

  it "update" do
    expect(patch: nonprofit_event_event_discount_path(nonprofit_id: nonprofit, event_id: event.id, id: event_discount.id)).to route_to(
      controller: "event_discounts",
      action: "update",
      nonprofit_id: nonprofit.id.to_s,
      event_id: event.id.to_s,
      id: event_discount.id.to_s
    )
  end
end
