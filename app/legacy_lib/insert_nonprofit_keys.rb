# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "httparty"
require "cypher"

module InsertNonprofitKeys
  include HTTParty

  def self.insert_mailchimp_access_token(npo_id, code)
    form_data = "grant_type=authorization_code&client_id=#{URI.escape ENV["MAILCHIMP_OAUTH_CLIENT_ID"]}&client_secret=#{ENV["MAILCHIMP_OAUTH_CLIENT_SECRET"]}&redirect_uri=#{ENV["MAILCHIMP_REDIRECT_URL"]}%2Fmailchimp-landing&code=#{URI.escape code}"

    response = post("https://login.mailchimp.com/oauth2/token", {body: form_data})
    if response["error"]
      raise Exception.new(response["error"])
    end

    nonprofit_key = Nonprofit.find(npo_id).nonprofit_key
    nonprofit_key ||= Nonprofit.find(npo_id).build_nonprofit_key

    nonprofit_key.mailchimp_token = response["access_token"]
    nonprofit_key.save!

    response["access_token"]
  end
end
