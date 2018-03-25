module Nonprofits
	class ActivitiesController < ApplicationController
		include NonprofitHelper
		before_filter :authenticate_nonprofit_user!

    # get /nonprofits/:nonprofit_id/supporters/:supporter_id/activities
    def index
      render json: QueryActivities.for_timeline(params[:nonprofit_id], params[:supporter_id])
    end

	end
end

