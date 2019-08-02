# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FrontController < ApplicationController
  def index
    if Nonprofit.none?
      redirect_to onboard_path
    elsif current_role?(%i[nonprofit_admin nonprofit_associate])
      redirect_to NonprofitPath.dashboard(administered_nonprofit)
    elsif current_user
      redirect_to '/profiles/' + current_user.profile.id.to_s
    else
      redirect_to new_user_session_path
    end
  end
end
