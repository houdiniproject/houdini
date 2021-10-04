# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Users::SessionsController < Devise::SessionsController
  layout 'layouts/apified', only: :new
  respond_to :json, only: :new

  def new
    @theme = 'minimal'
    super
  end

  def create
    @theme = 'minimal'

    respond_to do |format|
      format.json do
        warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
        render status: 200, json: { status: 'Success' }
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
      render json: { token: tok }, status: :ok
    else
      render json: ["Incorrect password. Please enter your #{Houdini.general.name} %> password."], status: :unprocessable_entity
    end
  end
end
