class CampaignGiftsController < ApplicationController

  # post /campaign_gifts
	def create
		json_saved CreateCampaignGift.create params[:campaign_gift]
	end
end
