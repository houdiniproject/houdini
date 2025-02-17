# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/campaigns/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:campaign, campaign)
    render
    JSON.parse(rendered)
  end

  let(:campaign) { create(:fv_poverty_fighting_campaign_with_nonprofit_and_profile) }
  let(:id) { json["id"] }
  let(:nonprofit) { campaign.nonprofit }

  it {
    is_expected.to include("object" => "campaign")
  }

  it {
    is_expected.to include("id" => campaign.id)
  }

  it {
    is_expected.to include("name" => campaign.name)
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(%r{http://test\.host/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}}))
  }
end
