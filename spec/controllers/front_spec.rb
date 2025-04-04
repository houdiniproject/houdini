# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe FrontController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'accept all' do
      describe 'index' do
          include_context :open_to_all, :get, :index
      end
    end
  end

  it 'index redirects to onboard with no non-profits' do
    get( :index)
    expect(response).to redirect_to onboard_url
  end

  describe 'have nonprofit info' do
    include_context :shared_user_context
    it 'redirect to nonprofit admin' do
      sign_in user_as_np_admin
      get(:index)
      expect(response).to redirect_to "/#{nonprofit.state_code_slug}/#{nonprofit.city_slug}/#{nonprofit.slug}/dashboard"
    end
    it 'redirect to nonprofit admin' do
      sign_in user_as_np_associate
      get(:index)
      expect(response).to redirect_to "/#{nonprofit.state_code_slug}/#{nonprofit.city_slug}/#{nonprofit.slug}/dashboard"
    end

    it 'redirect to general user' do
      nonprofit
      unauth_user.create_profile
      sign_in unauth_user
      get(:index)
      expect(response).to redirect_to profile_url(unauth_user.profile.id)
    end

  end
end