module CreateCampaignGiftOption

	def self.create campaign, params
		gift_option = campaign.campaign_gift_options.build params
		gift_option.save
		return gift_option
	end

end
