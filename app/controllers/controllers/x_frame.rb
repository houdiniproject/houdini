# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::XFrame
    extend ActiveSupport::Concern

    included do 
        private
        def deny_x_frame_option
            response.headers['X-Frame-Options'] = 'DENY'
        end

        def allow_in_frame
            response.headers.delete('X-Frame-Options')
        end
    end
end