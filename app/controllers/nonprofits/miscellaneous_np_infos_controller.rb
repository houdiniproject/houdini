# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
            update
          end
        end
      end
    end
  end
end
