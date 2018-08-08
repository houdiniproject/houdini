# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RolesController < ApplicationController
	include Controllers::NonprofitHelper

	before_filter :authenticate_nonprofit_admin!

	def create
		role = Role.create_for_nonprofit(params[:role][:name].to_sym, params[:role][:email], FetchNonprofit.with_params(params))
		json_saved role, "User successfully added!"
	end

	def destroy
		role = Role.find(params[:id])
		roles = role.user.roles.where(host_id: params[:nonprofit_id], name: role.name)
		unless roles.empty?
			roles.destroy_all
			flash[:notice] = 'User successfully removed'
			render json: {}
		else
			render json: {:error => "We couldn't find that admin"}, :status => :unprocessable_entity
		end
	end
end
