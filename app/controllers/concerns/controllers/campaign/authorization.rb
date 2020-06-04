# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::Campaign::Authorization
    extend ActiveSupport::Concern
    include Controllers::Nonprofit::Authorization

    included do
        private
        def current_campaign_editor?
            !params[:preview] && (current_nonprofit_user? || current_role?(:campaign_editor, current_campaign.id) || current_role?(:super_admin))
        end
        def authenticate_campaign_editor!
            unless current_campaign_editor?
                reject_with_sign_in 'You need to be a campaign editor to do that.'
            end
        end
    end
end