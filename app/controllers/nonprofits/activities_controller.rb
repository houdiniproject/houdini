# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
	class ActivitiesController < ApplicationController
		include Controllers::NonprofitHelper
		before_filter :authenticate_nonprofit_user!

    # get /nonprofits/:nonprofit_id/supporters/:supporter_id/activities
    def index
      render json: QueryActivities.for_timeline(params[:nonprofit_id], params[:supporter_id])
    end

	end
end

