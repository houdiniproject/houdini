# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreateCampaignGiftOption
  def self.create(campaign, params)
    gift_option = campaign.campaign_gift_options.build params
    gift_option.save
    gift_option
  end
end
