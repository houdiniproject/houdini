# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Campaigns; class CampaignGiftOptionsController < ApplicationController
	include Controllers::CampaignHelper

	before_filter :authenticate_campaign_editor!, only: [:index]

	def index
		respond_to do |format|
			format.json do
				render json: QueryCampaignGifts.report_metrics(current_campaign.id)
			end
		end
	end

end; end
