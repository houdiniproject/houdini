# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Users::SessionsController < Devise::SessionsController
  include ::Controllers::XFrame

  layout "layouts/apified", only: :new

  after_action :prevent_framing

  def new
    @theme = "minimal"
    super
  end

  def create
    @theme = "minimal"
    respond_to do |format|
      format.json do
        return auth_failed unless params[:user].present?

        email, password, otp_attempt = params[:user].values_at(:email, :password, :otp_attempt)

        user = User.find_for_authentication(email: email)

        return auth_failed unless user&.valid_password?(password)
        return sign_in_user(user) unless user.otp_required_for_login?

        return handle_otp_flow(user, otp_attempt)
      end
    end
  end

  # post /users/confirm_auth
  # A simple action to confirm an entered password for a user who is already signed in
  def confirm_auth
    if current_user.valid_password?(params[:password])
      tok = SecureRandom.uuid
      session[:pw_token] = tok
      session[:pw_timestamp] = Time.current.to_s
      render json: {token: tok}, status: :ok
    else
      render json: ["Incorrect password. Please enter your #{Settings.general.name} password."], status: :unprocessable_entity
    end
  end

  def send_otp
    respond_to do |format|
      format.json do
        email = params[:email]
        password = params[:password]
        user = User.find_for_authentication(email: email)

        return auth_failed unless user&.valid_password?(password)
        return render status: 422, json: ["OTP not required"] unless user.otp_required_for_login?

        UserMailer.otp_requested(user).deliver_later
        render status: 200, json: {status: "success"}
      end
    end
  end

  private

  def auth_failed
    render status: 401, json: ["Authentication failed"]
  end

  def sign_in_user(user)
    user.remember_me!
    sign_in(user)
    render status: 200, json: {status: "Success"}
  end

  def handle_otp_flow(user, otp_attempt)
    return render status: 200, json: {status: "otp_required"} if otp_attempt.blank?

    return auth_failed unless user.validate_and_consume_otp!(otp_attempt)

    sign_in_user(user)
  end
end
