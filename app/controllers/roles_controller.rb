# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RolesController < ApplicationController
  include Controllers::NonprofitHelper

  before_action :authenticate_nonprofit_admin!

  def create
    role = Role.create_for_nonprofit(params[:role][:name].to_sym, params[:role][:email], FetchNonprofit.with_params(params))
    json_saved role, "User successfully added!"
  end

  def destroy
    role = Role.find(params[:id])
    roles = role.user.roles.where(host_id: params[:nonprofit_id], name: role.name)
    if roles.empty?
      render json: {error: "We couldn't find that admin"}, status: :unprocessable_entity
    else
      roles.destroy_all
      flash[:notice] = "User successfully removed"
      render json: {}
    end
  end
end
