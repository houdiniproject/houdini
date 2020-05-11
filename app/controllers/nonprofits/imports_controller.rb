# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class ImportsController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!
    # post /nonprofits/:nonprofit_id/imports
    def create
      render_json do
        ImportCreationJob.perform_later(import_params, current_user)
      end
    end

    private

    def import_params
      params.permit(:nonprofit_id, :file_uri, :header_matches)
    end
  end
end
