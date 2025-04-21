# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe FrontController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "accept all" do
      describe "index" do
        include_context :open_to_all, :get, :index
      end
    end
  end

  describe "have nonprofit info" do
    include_context :shared_user_context
    it "redirect to nonprofit admin" do
      sign_in user_as_np_admin
      get(:index)
      expect(response).to redirect_to dashboard_nonprofit_path(nonprofit)
    end
    it "redirect to nonprofit admin" do
      sign_in user_as_np_associate
      get(:index)
      expect(response).to redirect_to dashboard_nonprofit_path(nonprofit)
    end

    it "redirect to general user" do
      nonprofit
      unauth_user.create_profile
      sign_in unauth_user
      get(:index)
      expect(response).to redirect_to profile_url(unauth_user.profile.id)
    end
  end
end
