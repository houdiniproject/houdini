# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Houdini::V1::Address, :type => :controller do
  include_context :shared_donation_charge_context
  include_context :shared_user_context
  describe :get do
    it '404s on invalid address' do
      xhr :get, '/api/v1/address/410595'
      expect(response.code).to eq "404"
    end

    describe '401s properly' do
      include_context :open_to_all, :get, '/api/v1/address/1'
    end
  end
end