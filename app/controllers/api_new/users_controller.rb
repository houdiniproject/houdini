# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ApiNew::UsersController < ApiNew::ApiController
  include Controllers::User::Authorization

  before_action :authenticate_user!

  # Returns the current user as JSON
  # If not logged in, causes a 401 error
  def current
    @user = current_user
  end

  # get /api_new/users/current_nonprofit_object_events
  def current_nonprofit_object_events
    np_houid = current_user.roles.where(host_type: "Nonprofit").first&.host&.houid
    if np_houid
      redirect_to api_new_nonprofit_object_events_path(np_houid, request.query_parameters)
    else
      render body: "Not Found", status: :not_found
    end
  end
end
