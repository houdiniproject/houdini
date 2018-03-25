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
