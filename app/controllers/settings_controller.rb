# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SettingsController < ApplicationController
	include Controllers::NonprofitHelper

	helper_method :current_nonprofit_user?
	before_filter :authenticate_user!

	def index
		if current_role?(:super_admin) && params[:nonprofit_id]
			@nonprofit = Nonprofit.find(params[:nonprofit_id])
		elsif current_role?([:nonprofit_admin, :nonprofit_associate])
			@nonprofit = administered_nonprofit
		end

    if current_role?(:super_admin) && params[:user_id]
      @user = User.find_by_id(params[:user_id])
    elsif current_role?(:super_admin) && params[:user_email]
      @user = User.find_by_email(params[:user_email])
    else
      @user = current_user
    end

		@profile = @user.profile

		if @nonprofit
			@miscellaneous_np_info = FetchMiscellaneousNpInfo.fetch(@nonprofit.id)
		end

	end

end
