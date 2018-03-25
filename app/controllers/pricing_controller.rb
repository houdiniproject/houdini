# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PricingController < ApplicationController
	include PricingHelper

	def index
		if current_role?(:super_admin) && params[:nonprofit_id]
			@nonprofit = Nonprofit.find(params[:nonprofit_id])
		else
			@nonprofit = administered_nonprofit
		end
	end
end
