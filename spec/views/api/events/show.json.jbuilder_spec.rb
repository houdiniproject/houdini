# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/events/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:event, event)
    render
    JSON.parse(rendered)
  end

  let(:event) { create(:fv_poverty_fighting_event_with_nonprofit_and_profile) }
  let(:id) { json["id"] }
  let(:nonprofit) { event.nonprofit }

  it {
    is_expected.to include("object" => "event")
  }

  it {
    is_expected.to include("id" => event.id)
  }

  it {
    is_expected.to include("name" => event.name)
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(%r{http://test\.host/api/nonprofits/#{nonprofit.id}/events/#{event.id}}))
  }
end
