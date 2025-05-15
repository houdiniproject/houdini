# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailSettingsController < ApplicationController
  include Controllers::NonprofitHelper
  before_action :authenticate_nonprofit_user!

  def index
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user
    es = QueryEmailSettings.fetch(params[:nonprofit_id], user.id)
    render json: es
  end

  # Create or update for a given user and nonprofit
  # post /nonprofits/:nonprofit_id/users/:user_id/email_settings for current_user
  def create
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user

    email_settings = user.email_settings.find_or_initialize_by(nonprofit: current_nonprofit)
    email_settings.update!(email_settings_params)
    render json: email_settings
  end

  private

  def email_settings_params
    params.require(:email_settings).permit(:notify_payments,
      :notify_campaigns,
      :notify_events,
      :notify_payouts,
      :notify_recurring_donations)
  end
end
