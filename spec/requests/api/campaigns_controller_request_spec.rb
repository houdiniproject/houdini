# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Api::CampaignsController do
  let(:campaign) { create(:fv_poverty_fighting_campaign_with_nonprofit_and_profile) }
  let(:nonprofit) { campaign.nonprofit }
  let(:user) { create(:user) }

  before do
    campaign
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end

  describe "GET /:id" do
    context "with nonprofit user" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

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
          a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}}))
      }
    end

    context "with campaign editor" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "campaign_editor", host: campaign)
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

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
          a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}}))
      }
    end

    context "with no user" do
      it "returns http success when logged in" do
        get "/api/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
