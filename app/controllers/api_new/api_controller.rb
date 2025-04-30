# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module ApiNew
  class ApiController < ActionController::Base # rubocop:disable Rails/ApplicationController
    # We disable Rails/ApplicationController because we don't want all the stuff in ApplicationController included since
    # the Api is simpler
    include Controllers::Locale
    include Controllers::Nonprofit::Authorization
    include Controllers::ApiNew::JbuilderExpansions
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_rescue
    rescue_from AuthenticationError, with: :unauthorized_rescue

    protected

    def record_invalid_rescue(error)
      render json: {errors: error.record.errors.messages}, status: :unprocessable_entity
    end

    def unauthorized_rescue(error)
      @error = error
      render "api_new/errors/unauthorized", status: :unauthorized
    end
  end
end
