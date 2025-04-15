# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Campaigns::CampaignGiftOptionsController, type: :request do
  
  let!(:campaign_gift_option) { create(:campaign_gift_option_base) }
  let(:campaign) { campaign_gift_option.campaign }
  let(:nonprofit) { campaign.nonprofit }

  describe "#index" do
    before(:each) do
      sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
    end

    it "returns properly" do
      get "/nonprofits/#{nonprofit.id}/campaigns/#{campaign.id}/campaign_gift_options", params: {format: :json}

      expect(JSON::parse(response.body)).to match "data" => [a_hash_including(
        campaign_gift_option.attributes.except('created_at', 'updated_at') # dates serialize funkily and we don't care at this moment
      )]
      expect(response).to have_http_status(:success)
    end
  end
end
