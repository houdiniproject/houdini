# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api_new/supporters/show.json.jbuilder", type: :view do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:supporter, supporter)
    render
    JSON.parse(rendered)
  end

  let(:supporter) { create(:supporter_with_fv_poverty, :with_primary_address) }
  let(:id) { json["id"] }
  let(:nonprofit) { supporter.nonprofit }

  it {
    is_expected.to include("object" => "supporter")
  }

  it {
    is_expected.to include("id" => supporter.houid)
  }

  it {
    is_expected.to include("legacy_id" => supporter.id)
  }

  it {
    is_expected.to include("name" => "Fake Supporter Name")
  }

  it {
    is_expected.to include("legacy_nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.houid)
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
    is_expected.to include("email" => supporter.email)
  }

  describe "supporter_addresses" do
    subject(:addresses) { json["supporter_addresses"] }
    it {
      expect(addresses.count).to eq 1
    }
    describe " with the only address" do
      subject(:sole_address) { addresses.first }
      it {
        is_expected.to include("address" => supporter.address)
      }

      it {
        is_expected.to include("city" => supporter.city)
      }

      it {
        is_expected.to include("state_code" => supporter.state_code)
      }

      it {
        is_expected.to include("zip_code" => supporter.zip_code)
      }

      it {
        is_expected.to include("country" => supporter.country)
      }
    end
  end

  # it {
  # 	is_expected.to include('url' =>
  # 		a_string_matching(%r{http://test\.host/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}}))
  # }
end
