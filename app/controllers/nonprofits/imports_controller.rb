# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class ImportsController < ApplicationController
    include Controllers::NonprofitHelper

    before_filter :authenticate_nonprofit_user!
    # post /nonprofits/:nonprofit_id/imports
    def create
      render_json{
        InsertImport.delay.from_csv_safe({
          nonprofit_id: params[:nonprofit_id],
          user_id: current_user.id,
          user_email: current_user.email,
          file_uri: params[:file_uri],
          header_matches: params[:header_matches]
        })
      }
    end
  end
end
