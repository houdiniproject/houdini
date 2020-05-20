# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class MiscellaneousNpInfosController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

    helper_method :current_nonprofit_user?
    before_action :authenticate_nonprofit_user!

    def show
      respond_to do |format|
        format.json do
          render_json { FetchMiscellaneousNpInfo.fetch(params[:nonprofit_id]) }
        end
      end
    end

    def update
      respond_to do |format|
        format.json do
          render_json do
            update = UpdateMiscellaneousNpInfo.update(params[:nonprofit_id], params[:miscellaneous_np_info])
            # flash[:notice] = "Your Miscellaneous Settings have been saved"
            update
          end
        end
      end
    end
  end
end
