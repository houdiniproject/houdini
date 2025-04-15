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
      get campaigns_campaign_gift_options_path(nonprofit_id: nonprofit.id, campaign_id: campaign.id), params: {format: :json}

      expect(JSON::parse(response.body)).to match "data" => [] # NOTE: this doesn't include campaign gift options if they don't have any donations. Why? Bad design, I think.
      expect(response).to have_http_status(:success)
    end
  end
end
