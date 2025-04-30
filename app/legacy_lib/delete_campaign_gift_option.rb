# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module DeleteCampaignGiftOption
  def self.delete(campaign, campaign_gift_option_id)
    ParamValidation.new({campaign: campaign,
                        campaign_gift_option_id: campaign_gift_option_id},
      {
        campaign: {
          required: true,
          is_a: Campaign
        },
        campaign_gift_option_id: {
          required: true,
          is_integer: true
        }
      })
    Qx.transaction do
      cgo = campaign.campaign_gift_options.where("id = ? ", campaign_gift_option_id).first
      unless cgo
        raise ParamValidation::ValidationError.new("#{campaign_gift_option_id} is not a valid gift option for campaign #{campaign.id}", {key: :campaign_gift_option_id})
      end

      if cgo.campaign_gifts.any?
        raise ParamValidation::ValidationError.new("#{campaign_gift_option_id} already has campaign gifts. It can't be deleted for safety reasons.", {key: :campaign_gift_option_id})
      end

      cgo.destroy

      cgo
    end
  end
end
