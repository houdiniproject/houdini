# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailSettingsController < ApplicationController
  include Controllers::NonprofitHelper
  before_filter :authenticate_nonprofit_user!

  def index
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user
    es = QueryEmailSettings.fetch(params[:nonprofit_id], user.id)
    render json: es
  end

  # Create or update for a given user and nonprofit
  # post /nonprofits/:nonprofit_id/users/:user_id/email_settings for current_user
  def create
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user
    render json: UpdateEmailSettings.save(params[:nonprofit_id], user.id, params[:email_settings])
  end

end

