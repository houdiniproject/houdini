# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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

  # post /confirm
  # set account password for an auto-generated account, using the token from its confirmation email
  def confirm
    @user = User.find_by(id: params[:id])
    token = params.dig(:user, :confirmation_token).to_s

    unless @user&.auto_generated && valid_confirmation_token?(@user, token)
      flash[:alert] = "That link is no longer valid. Please use the link in your most recent email."
      return redirect_to root_url
    end

    if @user.valid? && @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      @user.update_column(:confirmation_token, nil)
      flash[:notice] = "Your account is all set!"
      sign_in @user
      redirect_to session[:donor_signup_url] || root_url
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      redirect_to root_url
    end
  end

  def is_confirmed
    render json: {is_confirmed: User.find(params[:user_id]).confirmed?}
  end

  private

  # Devise stores either the raw token or its digest, depending on how it was generated
  def valid_confirmation_token?(user, token)
    return false if token.blank? || user.confirmation_token.blank?

    digest = Devise.token_generator.digest(User, :confirmation_token, token)
    Devise.secure_compare(user.confirmation_token, token) || Devise.secure_compare(user.confirmation_token, digest)
  end
end
