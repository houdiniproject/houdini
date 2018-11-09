# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Campaigns; class CampaignGiftOptionsController < ApplicationController
	include Controllers::CampaignHelper

	before_filter :authenticate_campaign_editor!, only: [:create, :destroy, :update, :update_order, :report]

	def report
		respond_to do |format|
			format.json do
				render json: QueryCampaignGifts.report_metrics(current_campaign.id)
			end
		end
	end



	def index
		@gift_options = current_campaign.campaign_gift_options.order('"order", amount_recurring, amount_one_time')
		render json: {data: @gift_options}
	end

	def show
		render json: {data: current_campaign.campaign_gift_options.find(params[:id])}
	end

	def create
		campaign = current_campaign
		json_saved CreateCampaignGiftOption.create(campaign, params[:campaign_gift_option]),
							 'Gift option successfully created!'
	end

	def update
		@campaign = current_campaign
		gift_option = @campaign.campaign_gift_options.find params[:id]
		json_saved UpdateCampaignGiftOption.update(gift_option, params[:campaign_gift_option]), 'Successfully updated'
	end

	# put /nonprofits/:nonprofit_id/campaigns/:campaign_id/campaign_gift_options/update_order
	# Pass in {data: [{id: 1, order: 1}]}
	def update_order
		updated_gift_options = UpdateOrder.with_data('campaign_gift_options', params[:data])
		render json: updated_gift_options
	end

	def destroy
		@campaign = current_campaign

		render_json { DeleteCampaignGiftOption.delete(@campaign, params[:id])}
	end

end; end
