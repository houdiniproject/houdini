# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe DeleteCampaignGiftOption do
  describe ".delete" do
    let(:nonprofit) { create(:nm_justice) }
    let(:profile) { force_create(:profile, user: force_create(:user)) }
    let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
    let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign) }
    let(:campaign_gift) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option) }

    it "cgo deletion is rejected because a gift has already been sold" do
      campaign_gift_option
      campaign_gift
      expect { DeleteCampaignGiftOption.delete(campaign_gift_option) }.to(raise_error do |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :campaign_gift_option_id}])
        expect(error.message).to eq("#{campaign_gift_option.id} already has campaign gifts. It can't be deleted for safety reasons.")

        expect(CampaignGiftOption.any?).to eq true
      end)
    end

    it "cgo deletion succeeds" do
      Timecop.freeze(2020, 10, 12) do
        campaign_gift_option
        result = DeleteCampaignGiftOption.delete(campaign_gift_option)
        expect(result).to be_a CampaignGiftOption
        expect(result.attributes).to eq campaign_gift_option.attributes
        expect(CampaignGiftOption.any?).to eq false
      end
    end
  end
end
