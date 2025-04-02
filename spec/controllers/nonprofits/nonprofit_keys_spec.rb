# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::NonprofitKeysController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'index' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'mailchimp_login' do
      include_context :open_to_np_associate, :get, :mailchimp_login, nonprofit_id: :__our_np

      it 'properly redirects to a mailchimp domain' do
        sign_in user_as_np_admin

        get :mailchimp_login, params: {nonprofit_id: nonprofit.id}

        expect(response).to redirect_to(%r{https://login\.mailchimp\.com.*})
      end
    end

    describe 'mailchimp_landing' do
      include_context :open_to_np_associate, :get, :mailchimp_landing, nonprofit_id: :__our_np
    end
  end
end