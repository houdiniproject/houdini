# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FrontController < ApplicationController
  def index
    if !Nonprofit.any?
      redirect_to onboard_path
    elsif current_role?([:nonprofit_admin, :nonprofit_associate])
      redirect_to slugged_nonprofit_dashboard_path(administered_nonprofit)
    elsif current_user
      redirect_to "/profiles/" + current_user.profile.id.to_s
    else
      redirect_to new_user_session_path
    end
  end
end
