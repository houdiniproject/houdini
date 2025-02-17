# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class ActivitiesController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    # get /nonprofits/:nonprofit_id/supporters/:supporter_id/activities
    def index
      render json: QueryActivities.for_timeline(params[:nonprofit_id], params[:supporter_id])
    end
  end
end
