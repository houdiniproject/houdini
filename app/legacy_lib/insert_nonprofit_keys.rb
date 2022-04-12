# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'httparty'
require 'cypher'


module InsertNonprofitKeys
  include HTTParty

    def self.insert_mailchimp_access_token(npo_id, code)
      form_data = "grant_type=authorization_code&client_id=#{URI.escape ENV['MAILCHIMP_OAUTH_CLIENT_ID']}&client_secret=#{ENV['MAILCHIMP_OAUTH_CLIENT_SECRET']}&redirect_uri=#{ENV['MAILCHIMP_REDIRECT_URL']}%2Fmailchimp-landing&code=#{URI.escape code}"

      response = post('https://login.mailchimp.com/oauth2/token', { body: form_data })
      if response['error']
        raise Exception.new(response['error'])
      end
      response['access_token'] = Cypher.encrypt(response['access_token'])

      key_row_id = Qx.select("*")
        .from(:nonprofit_keys).where(nonprofit_id: npo_id)
        .execute.map{|h| h['id']}.first

      if key_row_id.nil?
        Qx.insert_into(:nonprofit_keys)
          .values({nonprofit_id: npo_id, mailchimp_token: response['access_token'].to_json})
          .ts.execute
      else
        Qx.update(:nonprofit_keys)
          .set(mailchimp_token: response['access_token'])
          .ts.where({'id' => key_row_id})
          .execute
      end

      return response['access_token']
    end
end
