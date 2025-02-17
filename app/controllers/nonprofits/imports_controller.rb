# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class ImportsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!
    # post /nonprofits/:nonprofit_id/imports
    def create
      render_json do
        request = ImportRequest.create(import_params)
        ImportCreationJob.perform_later(request, current_user)
      end
    end

    private

    def import_params
      params.permit(:nonprofit_id, :import_file, header_matches: {})
    end
  end
end
