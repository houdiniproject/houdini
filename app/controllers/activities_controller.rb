class ActivitiesController < ApplicationController

	before_filter :authenticate_user!, only: [:create]

	def create
		json_saved Activity.create(params[:activity])
	end

end
