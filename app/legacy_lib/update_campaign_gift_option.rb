# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateCampaignGiftOption
  def self.update gift_option, params
    gift_option.update_attributes params
    gift_option
  end
end
