# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module Nonprofits
class NonprofitKeysController < ApplicationController
  include Controllers::NonprofitHelper
  before_filter :authenticate_nonprofit_user!

  # get /nonprofits/:nonprofit_id/nonprofit_keys
  # pass in the :select query param, which is the name of the column of the specific token you want
  def index
    render_json{QueryNonprofitKeys.get_key(current_nonprofit.id, params[:select])}
  end

  # Redirects to the mailchimp OAuth2 landing page, first setting the nonprofit id in the session
  # GET /nonprofits/:nonprofit_id/nonprofit_keys/mailchimp_login
  def mailchimp_login
    session[:current_mailchimp_nonprofit_id] = current_nonprofit.id
    redirect_to "https://login.mailchimp.com/oauth2/authorize?response_type=code&client_id=#{ENV['MAILCHIMP_OAUTH_CLIENT_ID']}"
  end

  # After the user OAuths mailchimp, they are redirected to /mailchimp-landing
  # This action then redirects them back to /settings
  # GET /mailchimp-landing
  def mailchimp_landing
    @nonprofit = Nonprofit.find(session[:current_mailchimp_nonprofit_id])
    session.delete(:current_mailchimp_nonprofit_id)
    begin
      session[:mailchimp_access_token] = InsertNonprofitKeys.insert_mailchimp_access_token(@nonprofit.id, params[:code])
    rescue Exception => e
      flash[:notice] = "Unable to connect to your Mailchimp account, please try again. (Error: #{e})"
      redirect_to '/settings'
      return
    end
    redirect_to nonprofits_supporters_path @nonprofit, 'show-modal' => 'mailchimpSettingsModal'
  end

end
end
