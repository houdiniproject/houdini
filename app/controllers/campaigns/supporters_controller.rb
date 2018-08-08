# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Campaigns
class SupportersController < ApplicationController
	include Controllers::CampaignHelper

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
