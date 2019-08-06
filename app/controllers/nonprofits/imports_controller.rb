# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class ImportsController < ApplicationController
    include Controllers::NonprofitHelper

    before_action :authenticate_nonprofit_user!
    # post /nonprofits/:nonprofit_id/imports
    def create
      render_json do
        InsertImport.delay.from_csv_safe(
          nonprofit_id: import_params[:nonprofit_id],
          user_id: current_user.id,
          user_email: current_user.email,
          file_uri: import_params[:file_uri],
          header_matches: import_params[:header_matches]
        )
      end
    end

    private

    def import_params
      params.permit(:nonprofit_id, :file_uri, :header_matches)
    end
  end
end
