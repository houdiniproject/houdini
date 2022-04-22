# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class EmailSettingsController < ApplicationController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
  before_action :authenticate_nonprofit_user!

  def index
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user
    email_settings = QueryEmailSettings.fetch(params[:nonprofit_id], user.id)
    render json: email_settings
  end

  # Create or update for a given user and nonprofit
  # post /nonprofits/:nonprofit_id/users/:user_id/email_settings for current_user
  def create
    user = current_role?(:super_admin) ? User.find(params[:user_id]) : current_user
    render json: UpdateEmailSettings.save(params[:nonprofit_id], user.id, email_settings_params)
  end

  private

  def email_settings_params
    params.require(:email_settings).permit(:notify_payments, :notify_campaigns, :notify_events, :notify_payouts, :notify_recurring_donations)
  end
end
