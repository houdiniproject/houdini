# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::XFrame
    extend ActiveSupport::Concern

    included do 
        private
        def add_x_frame_options
            response.headers['X-Frame-Options'] = 'DENY'
        end
    end
end