# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Users::SessionsController < Devise::SessionsController
  layout "layouts/material", only: :new
  respond_to :json, only: [:new, :create]
  skip_before_action :verify_authenticity_token

  # POST /resource/sign_in
  # we override becuase we don't want to redirect when a session is created
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    @user = resource
  end

  # post /users/confirm_auth
  # A simple action to confirm an entered password for a user who is already signed in
  def confirm_auth
    if current_user.valid_password?(params[:password])
      token = SecureRandom.uuid
      session[:pw_token] = token
      session[:pw_timestamp] = Time.current.to_s
      render json: {token: token}, status: :ok
    else
      render json: ["Incorrect password. Please enter your #{Houdini.general.name} %> password."], status: :unprocessable_entity
    end
  end
end
