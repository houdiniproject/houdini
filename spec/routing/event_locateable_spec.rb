# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe "event_locatable" do
  # for reasons I don't understand, routing specs don't have the defautlt_url_options set so we set them here.
  around do |example|
    original_url_options = Rails.application.routes.default_url_options.dup
    Rails.application.routes.default_url_options.merge!(protocol: "http", host: "test.example.com", port: 3001)
    example.run
    Rails.application.routes.default_url_options = original_url_options
  end

  let(:event) { create(:fv_poverty_fighting_event_with_nonprofit_and_profile) }
  let(:nonprofit) { event.nonprofit }

  it "routes with event" do
    expect(get: event_locateable_path(event)).to route_to(
      controller: "events",
      action: "show",
      state_code: nonprofit.state_code_slug, city: nonprofit.city_slug, name: nonprofit.slug,
      event_slug: event.slug
    )
  end
end
