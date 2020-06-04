# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::Campaign::Current
    extend ActiveSupport::Concern
    include Controllers::Nonprofit::Current

    included do
        private
        def current_campaign
            @campaign ||= FetchCampaign.with_params params, current_nonprofit
            raise ActionController::RoutingError, 'Campaign not found' if @campaign.nil?
        
            @campaign
        end
    end
end