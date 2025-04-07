# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Users::ConfirmationsController < Devise::ConfirmationsController
  # get /confirm
  def show
    @user = User.confirm_by_token(params[:confirmation_token])

    if !@user.auto_generated || !@user.valid?
      flash[:notice] = "We successfully confirmed your account"
      redirect_to session[:donor_signup_url] || root_url
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def exists
    render json: User.find_by_email(params[:email])
  end

  # post /confirm
  # set account password
  def confirm
    @user = User.find(params[:id])

    if @user.valid? && @user.update(params[:user].except(:confirmation_token))
      flash[:notice] = "Your account is all set!"
      sign_in @user
      redirect_to session[:donor_signup_url] || root_url
    else
      session[:donor_signup_url] || root_url
    end
  end

  def is_confirmed
    render json: {is_confirmed: User.find(params[:user_id]).confirmed?}
  end
end
