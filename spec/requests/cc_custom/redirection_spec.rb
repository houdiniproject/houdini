# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

StateCodes = Set.new([ 'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY' ])
ActualStateCodes = ["ny", "la", "ca", "va", "nh", "oh", "fl", "wa", "nj", "nd", "il", "vt", "al", "tx", "state", "dc", "co", "mo", "ab", "mi", "ma", "de", "nv", "pa", "ct", "ar", "az", "in", "ky", "md", "nc", "ne", "ut", "ok", "ks", "ak", "wi", "ga", "or", "mn", "tn", "mt", "wv", "me", "ms", "tat", "bc", "nm", "ri", "sc", "sd", "india", "hi", "id", "california", "british-columbia", "utah", "lagos", "arkansas", "albany", "greater-accra-region", "new-york-ny", "west-bengal", "colombp", "yemen", "illinois", "sthlm", "massachusetts", "pichincha", "sp", "nt", "et", "paris", "ha-ti", "tanzania", "western-cape", "florida", "uttarakhand", "washington", "nevada", "louisiana", "germany", "michigan", "bru", "wb", "ab-alberta", "qc---quebec", "nsw", "sa", "ir", "on", "texas", "harare", "no", "usa", "america"].map{|i| i.upcase}
OtherRedirects = ['nonprofits', 'events', 'recurring_donations', 'profiles', 'js', 'css', 'assets']
StartDomain = "https://commitchange.mystagingwebsite.com/"
EndDomain = "https://us.commitchange.com/"

describe 'redirections', type: :request do
  around(:each) {|i|
    WebMock.allow_net_connect!
    i.run()
    WebMock.disable_net_connect!
  }
  it 'states are successful' do
    StateCodes.merge(ActualStateCodes).each do |state|
      runRedirectionTest(state.downcase)
    end
  end

  it 'other redirects, not states' do
    OtherRedirects.each do |redirect|
      runRedirectionTest(redirect.downcase)
    end
  end

  def runRedirectionTest(state_version)
    result = HTTParty.get "#{StartDomain}#{state_version}/1", follow_redirects: false
    expect(result.response.code).to eq("302"), "expected #{StartDomain}#{state_version}/1 to return 302, instead got #{result.response.code}"
    expect(result.response.header['location']).to eq "#{EndDomain}#{state_version.downcase}/1"

    result = HTTParty.get "#{StartDomain}#{state_version}/1/1", follow_redirects: false
    expect(result.response.code).to eq("302"), "expected #{StartDomain}#{state_version}/1/1 to return 302, instead got #{result.response.code}"
    expect(result.response.header['location']).to eq "#{EndDomain}#{state_version.downcase}/1/1"

    result = HTTParty.get "#{StartDomain}#{state_version}", follow_redirects: false
    expect(["301", "404"]).to include(result.response.code), "expected #{StartDomain}#{state_version} to return 301 or 404, instead got #{result.response.code}"

    if (result.response.code == "301")
      expect(result.response.header['location']).to start_with StartDomain
    end

  end
end

