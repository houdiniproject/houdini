# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::CampaignHelper
	include Controllers::NonprofitHelper

private

	def current_campaign
		@campaign ||= FetchCampaign.with_params params, current_nonprofit
		raise ActionController::RoutingError.new "Campaign not found" if @campaign.nil?
		return @campaign
	end

	def current_campaign_editor?
		 !params[:preview] && (current_nonprofit_user? || current_role?(:campaign_editor, current_campaign.id) || current_role?(:super_admin))
	end

	def authenticate_campaign_editor!
		unless current_campaign_editor?
			block_with_sign_in 'You need to be a campaign editor to do that.'
		end
	end

end
