# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class FrontController < ApplicationController
  def index
    if current_role?(%i[nonprofit_admin nonprofit_associate])
      redirect_to dashboard_nonprofit_path(administered_nonprofit)
    elsif current_user
      redirect_to '/profiles/' + current_user.profile.id.to_s
    else
      redirect_to new_user_session_path
    end
  end
end
