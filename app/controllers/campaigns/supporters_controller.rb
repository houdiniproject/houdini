module Campaigns
class SupportersController < ApplicationController
	include CampaignHelper

	before_filter :authenticate_campaign_editor!, only: [:index]

	def index
		@panels_layout = true
		@nonprofit = current_nonprofit
		@campaign  = current_campaign

		respond_to do |format|
			format.json do
				render json: QuerySupporters.campaign_list(@nonprofit.id, @campaign.id, params)
			end
			format.html
		end
	end

end
end
