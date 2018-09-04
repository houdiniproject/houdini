# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::NonprofitHelper

private

	def authenticate_nonprofit_user!
		unless current_nonprofit_user?
			block_with_sign_in 'Please sign in'
		end
	end

	def authenticate_nonprofit_admin!
		unless current_nonprofit_admin?
			block_with_sign_in 'Please sign in'
		end
	end

	def authenticate_min_nonprofit_plan plan_tier
		unless current_nonprofit_user? && current_plan_tier >= plan_tier
			block_with_sign_in 'Please sign in'
		end
	end

	def current_nonprofit_user?
    return false if params[:preview]
		return false unless current_nonprofit_without_exception
		@current_user_role ||= current_role?([:nonprofit_admin, :nonprofit_associate], current_nonprofit_without_exception.id) || current_role?(:super_admin)
	end

	def current_nonprofit_admin?
		return false if !current_user || current_user.roles.empty?
		@current_admin_role ||= current_role?(:nonprofit_admin, current_nonprofit.id) || current_role?(:super_admin)
	end

	def current_nonprofit
		@nonprofit = current_nonprofit_without_exception
		raise ActionController::RoutingError.new "Nonprofit not found" if @nonprofit.nil?
		return @nonprofit
	end

	def current_nonprofit_without_exception
		key = "current_nonprofit_#{current_user_id}_params_#{[params[:state_code], params[:city], params[:name], params[:nonprofit_id], params[:id]].join("_")}"
    FetchNonprofit.with_params params, administered_nonprofit
	end

	def donation_stub
		return current_nonprofit_without_exception.donations.last unless current_nonprofit_without_exception.donations.empty?
		OpenStruct.new(
			amount: 2000,
			created_at: Time.zone.now,
			nonprofit: current_nonprofit_without_exception,
			campaign: nil,
			designation: "Donor's designation here",
			dedication: "Donor's dedication here",
			id: 1
		)
	end

end
