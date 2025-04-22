# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  def new
    super
  end

  # this endpoint only creates donor users
  def create
    clean_params[:user][:referer] = session[:referer_id]
    user = User.register_donor!(clean_params[:user])
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
      success = current_user.update(params[:user])
      errs = current_user.errors.full_messages
    else
      success = false
      errs = {password: :incorrect}
    end

    if success
      flash[:notice] = if params[:user][:email].present?
        "We need to confirm your new email address. Check your inbox for a confirmation link."
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

  def clean_params
    params.permit(user: [:name, :email, :password_confirmation, :password])
  end
end
