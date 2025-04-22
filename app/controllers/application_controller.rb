# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ApplicationController < ActionController::Base
  include Controllers::Locale
  include Controllers::Nonprofit::Authorization
  before_action :redirect_to_maintenance
  around_action :switch_locale
  protect_from_forgery

  private

  def redirect_to_maintenance
    if Houdini.maintenance&.active && !current_user
      unless self.class == Users::SessionsController &&
          ((Houdini.maintenance.token && params[:maintenance_token] == Houdini.maintenance.token) || params[:format] == "json")
        redirect_to Houdini.maintenance.page
      end
    end
  end

  protected

  def json_saved(model, msg = nil)
    if model.valid?
      flash[:notice] = msg if msg
      render json: model, status: 200
    else
      render json: model.errors.full_messages, status: :unprocessable_entity
    end
  end

  # A response helper for use with the param_validation gem
  # use like:   render_json{ UpdateUsers.update(params[:user]) }
  # will catch and pretty print exceptions using the rails loggers
  def render_json(&block)
    begin
      result = {status: 200, json: yield(block)}
    rescue ParamValidation::ValidationError => e
      logger.info "422: #{e}".red.bold
      result = {status: 422, json: {error: e.message}}
    rescue HoudiniError => e
      logger.info "422: #{e}".red.bold
      result = {status: 422, json: {error: e.message}}
    rescue ActiveRecord::RecordNotFound => e
      logger.info "404: #{e}".red.bold
      result = {status: 404, json: {error: e.message}}
    rescue AuthenticationError => e
      logger.info "401: #{e}".red.bold
      result = {status: 401, json: {error: e.message}}
    rescue ExpiredTokenError => e
      logger.info "422: #{e}".red.bold
      result = {status: 422, json: {error: e.message}}
    rescue Exception => e # a non-validation related exception
      logger.error "500: #{e}".red.bold
      logger.error e.backtrace.take(5).map { |l| ">>".red.bold + " #{l}" }.join("\n").red
      result = {status: 500, json: {error: e.message, backtrace: e.backtrace}}
    end
    render result
  end

  # Test that within the last 5 minutes, the user has confirmed their password
  def password_was_confirmed(token)
    session[:pw_token] == token && Chronic.parse(session[:pw_timestamp]) >= 5.minutes.ago.utc
  end

  # devise config

  def after_sign_in_path_for(_resource)
    request.env["omniauth.origin"] || session[:previous_url] || root_path
  end

  def after_sign_up_path_for(_resource)
    request.env["omniauth.origin"] || session[:previous_url] || root_path
  end

  def after_update_path_for(_resource)
    profile_path(current_user.profile)
  end

  def after_inactive_sign_up_path_for(_resource)
    profile_path(current_user.profile)
  end
end
