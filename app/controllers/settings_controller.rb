# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SettingsController < ApplicationController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

  helper_method :current_nonprofit_user?
  before_action :authenticate_user!

  def index
    if current_role?(:super_admin) && params[:nonprofit_id]
      @nonprofit = Nonprofit.find(params[:nonprofit_id])
    elsif current_role?(%i[nonprofit_admin nonprofit_associate])
      @nonprofit = administered_nonprofit
    end

    @user = if current_role?(:super_admin) && params[:user_id]
      User.find_by_id(params[:user_id])
    elsif current_role?(:super_admin) && params[:user_email]
      User.find_by_email(params[:user_email])
    else
      current_user
    end

    @profile = @user.profile

    if @nonprofit
      @miscellaneous_np_info = FetchMiscellaneousNpInfo.fetch(@nonprofit.id)
    end
  end
end
