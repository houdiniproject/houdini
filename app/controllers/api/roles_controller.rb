# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Api::RolesController < Api::ApiController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
  before_action :authenticate_nonprofit_user!

  # get /nonprofits/:nonprofit_id/roles
  def index
    @roles = current_nonprofit.roles.page(params[:page]).per(params[:per])
  end
end
