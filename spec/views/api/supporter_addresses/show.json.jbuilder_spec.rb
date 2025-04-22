# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/supporter_addresses/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:supporter_address, supporter_address)
    render
    JSON.parse(rendered)
  end

  let(:supporter) { create(:supporter_with_fv_poverty) }
  let(:id) { json["id"] }
  let(:nonprofit) { supporter.nonprofit }

  let(:supporter_address) { supporter }

  it {
    is_expected.to include("object" => "supporter_address")
  }

  it {
    is_expected.to include("id" => supporter_address.id)
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("deleted" => false)
  }

  it {
    is_expected.to include("supporter" => supporter.id)
  }

  it {
    is_expected.to include("address" => supporter_address.address)
  }

  it {
    is_expected.to include("city" => supporter_address.city)
  }

  it {
    is_expected.to include("state_code" => supporter_address.state_code)
  }

  it {
    is_expected.to include("country" => supporter_address.country)
  }

  it {
    is_expected.to include("zip_code" => supporter_address.zip_code)
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(
        %r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}} # rubocop:disable Layout/LineLength
      ))
  }
end
