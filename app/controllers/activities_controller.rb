# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ActivitiesController < ApplicationController

	before_action :authenticate_user!, only: [:create]

	def create
		json_saved Activity.create(params[:activity])
	end

end
