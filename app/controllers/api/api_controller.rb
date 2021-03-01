# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Api::ApiController < ActionController::Base
    include Controllers::Locale
    include Controllers::Nonprofit::Authorization
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_rescue
    
    protected
    
    def record_invalid_rescue(error)
        render json:{errors: error.record.errors.messages}, status: :unprocessable_entity
    end

end