# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module DeleteCampaignGiftOption
  def self.delete(campaign_gift_option)
    CampaignGiftOption.transaction do
      if campaign_gift_option.campaign_gifts.any?
        raise ParamValidation::ValidationError.new("#{campaign_gift_option&.id} already has campaign gifts. It can't be deleted for safety reasons.", key: :campaign_gift_option_id)
      end

      campaign_gift_option.destroy

      campaign_gift_option
    end
  end
end
