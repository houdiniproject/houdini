# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe DeleteCampaignGiftOption do
  describe '.delete' do
    let(:profile) { force_create(:profile, user: force_create(:user)) }
    let(:campaign) { force_create(:campaign, profile: profile) }
    let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign) }
    let(:campaign_gift) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option) }
    describe 'param validation' do
      it 'does basic validation' do
        expect do
          DeleteCampaignGiftOption.delete(nil,
                                          nil)
        end
          .to(raise_error  do |error|
                expect(error).to be_a ParamValidation::ValidationError
                expect_validation_errors(error.data, [
                                           {
                                             key: :campaign,
                                             name: :required
                                           },
                                           {
                                             key: :campaign,
                                             name: :is_a
                                           },
                                           {
                                             key: :campaign_gift_option_id,
                                             name: :required
                                           },
                                           {
                                             key: :campaign_gift_option_id,
                                             name: :is_integer
                                           }
                                         ])
              end)
      end

      it 'does cgo verification' do
        expect { DeleteCampaignGiftOption.delete(campaign, 5555) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{ key: :campaign_gift_option_id }])
        end)
      end
    end

    it 'cgo deletion is rejected because a gift has already been sold' do
      campaign_gift_option
      campaign_gift
      expect { DeleteCampaignGiftOption.delete(campaign, campaign_gift_option.id) }.to(raise_error do |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{ key: :campaign_gift_option_id }])
        expect(error.message).to eq("#{campaign_gift_option.id} already has campaign gifts. It can't be deleted for safety reasons.")

        expect(CampaignGiftOption.any?).to eq true
      end)
    end

    it 'cgo deletion succeeds' do
      Timecop.freeze(2020, 10, 12) do
        campaign_gift_option
        result = DeleteCampaignGiftOption.delete(campaign, campaign_gift_option.id)
        expect(result).to be_a CampaignGiftOption
        expect(result.attributes).to eq campaign_gift_option.attributes
        expect(CampaignGiftOption.any?).to eq false
      end
    end
  end
end
