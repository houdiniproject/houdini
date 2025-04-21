# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/supporters/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:supporter, supporter)
    render
    JSON.parse(rendered)
  end

  let(:supporter) { create(:supporter_with_fv_poverty) }
  let(:id) { json["id"] }
  let(:nonprofit) { supporter.nonprofit }

  it {
    is_expected.to include("object" => "supporter")
  }

  it {
    is_expected.to include("id" => supporter.id)
  }

  it {
    is_expected.to include("name" => "Fake Supporter Name")
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("anonymous" => false)
  }

  it {
    is_expected.to include("deleted" => false)
  }

  it {
    is_expected.to include("merged_into" => nil)
  }

  it {
    is_expected.to include("organization" => nil)
  }

  it {
    is_expected.to include("phone" => nil)
  }

  it {
    is_expected.to include("supporter_addresses" => [id])
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(%r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
  }
end
