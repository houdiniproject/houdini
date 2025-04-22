# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ApplicationController < ActionController::Base
  before_action :set_locale, :redirect_to_maintenance

  protect_from_forgery with: :exception

  helper_method \
    :current_role?,
    :current_nonprofit_user?,
    :administered_nonprofit

  delegate :administered_nonprofit, to: :current_user, allow_nil: true

  def set_locale
    I18n.locale = if params[:locale] && Settings.available_locales.include?(params[:locale])
      params[:locale]
    else
      Settings.language
    end
  end

  def redirect_to_maintenance
    if Settings&.maintenance&.maintenance_mode && !current_user
      unless self.class == Users::SessionsController &&
          ((Settings.maintenance.maintenance_token && params[:maintenance_token] == Settings.maintenance.maintenance_token) || params[:format] == "json")
        redirect_to Settings.maintenance.maintenance_page,
          allow_other_host: true
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
      # logger.info ">>".bold.red + " #{{'Failed key name' => e.data[:key], 'Value' => e.data[:val], 'Failed validator' => e.data[:name]}}".red
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

  def store_location
    referrer = request.fullpath
    no_redirects = ["/users", "/signup", "/signin", "/users/sign_in", "/users/sign_up", "/users/password", "/users/sign_out", /.*\.json.*/, /.*auth\/facebook.*/]
    unless request.format.symbol == :json || no_redirects.map { |p| referrer.match(p) }.any?
      session[:previous_url] = referrer
    end
  end

  def block_with_sign_in(msg = nil)
    store_location
    if current_user
      flash[:notice] = "It looks like you're not allowed to access that page. If this seems like a mistake, please contact #{Settings.mailer.email}"
      redirect_to root_path
    else
      msg ||= "We need to sign you in before you can do that."
      redirect_to new_user_session_path, flash: {error: msg}
    end
  end

  def authenticate_user!(options = {})
    block_with_sign_in unless current_user
  end

  def authenticate_confirmed_user!
    if !current_user
      block_with_sign_in
    elsif !current_user.confirmed? && !current_role?([:super_associate, :super_admin])
      redirect_to new_user_confirmation_path, flash: {error: "You need to confirm your account to do that."}
    end
  end

  def authenticate_super_associate!
    unless current_role?(:super_admin) || current_role?(:super_associate)
      block_with_sign_in "Please login."
    end
  end

  def authenticate_super_admin!
    unless current_role?(:super_admin)
      block_with_sign_in "Please login."
    end
  end

  def current_role?(role_names, host_id = nil)
    return false unless current_user
    role_names = Array(role_names)
    QueryRoles.user_has_role?(current_user.id, role_names, host_id)
  end

<<<<<<< HEAD
	# devise config
=======
  def administered_nonprofit
    return nil unless current_user
    Nonprofit.where(id: QueryRoles.host_ids(current_user_id, [:nonprofit_admin, :nonprofit_associate])).last
  end

  # devise config
>>>>>>> a41d3d25 (Run standard fix)

  def after_sign_in_path_for(resource)
    request.env["omniauth.origin"] || session[:previous_url] || root_path
  end

  def after_sign_up_path_for(resource)
    request.env["omniauth.origin"] || session[:previous_url] || root_path
  end

  def after_update_path_for(resource)
    profile_path(current_user.profile)
  end

  def after_inactive_sign_up_path_for(resource)
    profile_path(current_user.profile)
  end

  # /devise config

  private

  def current_user_id
    current_user && current_user.id
  end

  # Overload handle_unverified_request to ensure that
  # exception is raised each time a request does not
  # pass validation.
  def handle_unverified_request
    Airbrake.notify(ActionController::InvalidAuthenticityToken, params: params)
  end
end
