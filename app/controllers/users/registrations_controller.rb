# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  before_action :verify_via_recaptcha!, only: [:create]

  rescue_from ::Recaptcha::RecaptchaError, with: :handle_recaptcha_failure

  def new
    super
  end

  # this endpoint only creates donor users
  def create
    user = User.register_donor!({referer: session[:referer_id]}.merge(params[:user].to_deprecated_h))
    if user.save
      sign_in user
      render json: user
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
      clean_up_passwords(user)
    end
  end

  # If a user registered via OAuth, allow them to set their password and email
  # without confirming their current password.  # Otherwise, they need to confirm their current password.
  # See: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  def update
    # User either registered with Oauth and hasn't set a password or has entered a valid password
    if current_user.pending_password || current_user.valid_password?(params[:user][:current_password])
      # If the user updates their password, they are no longer flagged as 'pending_password'
      if current_user.pending_password && params[:user][:password] && params[:user][:password_confirmation]
        params[:user][:pending_password] = false
      end

      handle_two_factor_changes

      success = current_user.update_attributes(update_params)
      errs = current_user.errors.full_messages
    else
      success = false
      errs = {password: :incorrect}
    end

    if success
      flash[:notice] = if params[:user][:email].present?
        "We need to confirm your new email address. Check your inbox for a confirmation link."
      elsif current_user.saved_change_to_otp_required_for_login?
        two_factor_change_message
      else
        "Account updated!"
      end
      sign_in(current_user, bypass: true)
      render json: current_user
    else
      render json: {errors: errs}, status: :unprocessable_entity
    end
  end

  private

  def verify_via_recaptcha!
    verify_recaptcha!(action: "create_user", minimum_score: ENV["MINIMUM_RECAPTCHA_SCORE"].to_f)
  rescue ::Recaptcha::RecaptchaError => e
    failure_details = {
      params: params,
      action: "create_user",
      minimum_score_required: ENV["MINIMUM_RECAPTCHA_SCORE"],
      recaptcha_result: recaptcha_reply,
      recaptcha_value: params["g-recaptcha-response"]
    }
    failure = RecaptchaRejection.new
    failure.details = failure_details
    failure.save!
    raise e
  end

  def handle_recaptcha_failure
    render json: {error: "There was an temporary error preventing your payment. Please try again. If it persists, please contact support@commitchange.com with error code: 5X4J "}, status: :unprocessable_entity
  end

  def update_params
    params[:user].except(:otp_required_for_login)
  end

  def handle_two_factor_changes
    return if current_user.two_factor_required_by_nonprofit?

    otp_param = params[:user][:otp_required_for_login]
    return if otp_param.blank?

    current_user.otp_required_for_login = otp_param

    if current_user.otp_required_for_login_changed?
      current_user.otp_secret = if current_user.otp_required_for_login?
        User.generate_otp_secret
      end
    end
  end

  def two_factor_change_message
    if current_user.otp_required_for_login?
      "Two-factor authentication has been enabled! You'll receive a one-time password via email on future logins."
    else
      "Two-factor authentication has been disabled."
    end
  end
end
