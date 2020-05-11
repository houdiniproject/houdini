# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Api::ApiController < ApplicationController
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_rescue
    
    protected
    
    def record_invalid_rescue(error)
        render json:{errors: error.record.errors.messages}, status: :unprocessable_entity
    end

end