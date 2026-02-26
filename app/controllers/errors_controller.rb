# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

class ErrorsController < ActionController::Base
    def not_found
        render status: 404
    end

    def internal_server_error
        render status: 500
    end

    def unprocessable
        render status: 422
    end
end