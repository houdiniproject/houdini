# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CreateCampaignGiftOption
  def self.create campaign, params
    gift_option = campaign.campaign_gift_options.build params
    gift_option.save
    gift_option
  end
end
