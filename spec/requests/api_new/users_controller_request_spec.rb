# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe ApiNew::UsersController, type: :request do
  context "for unlogged in user" do
    it "returns unauthorized when not logged in" do
      get "/api_new/users/current"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "for a nonprofit admin" do
    let(:user) { create(:user_base, roles: [build(:role_base, :as_nonprofit_admin)]) }

    subject(:body) { response.body }
    before do
      sign_in user
      get "/api_new/users/current"
    end

    it {
      expect(response).to have_http_status(:success)
    }

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: false,
        roles: [
          {
            host: Nonprofit.first.to_houid
          }
        ]
      )
    }
  end

  context "for a nonprofit associate" do
    let(:user) { create(:user_as_nonprofit_associate) }

    subject(:body) { response.body }
    before do
      sign_in user
      get "/api_new/users/current"
    end

    it {
      expect(response).to have_http_status(:success)
    }

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: false,
        roles: []
      )
    }
  end

  context "for super admin" do
    let(:user) { create(:user_as_super_admin) }

    subject(:body) { response.body }
    before do
      sign_in user
      get "/api_new/users/current"
    end

    it {
      expect(response).to have_http_status(:success)
    }

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: true,
        roles: []
      )
    }
  end

  context "test using basic auth (testing that Devise.http_authenticatable works)" do
    let(:user) { create(:user_as_nonprofit_associate, password: "valid_password") }

    subject(:body) { response.body }

    describe "with correct password" do
      before do
        get "/api_new/users/current", headers: {authorization: "Basic #{Base64.encode64("#{user.email}:valid_password")}"}
      end

      it {
        expect(response).to have_http_status(:success)
      }
    end

    describe "with incorrect password" do
      before do
        get "/api_new/users/current", headers: {authorization: "Basic #{Base64.encode64("#{user.email}:BAD_PASSWORD")}"}
      end

      it {
        expect(response).to have_http_status(:unauthorized)
      }
    end
  end

  context "GET /api_new/users/current_nonprofit_object_events" do
    let(:nonprofit_user) { create(:user_as_nonprofit_associate) }
    let(:no_nonprofit_user) { create(:user) }

    it "redirects to api_new/object_events#index for the user's nonprofit when the user has one" do
      sign_in nonprofit_user
      get current_nonprofit_object_events_api_new_users_path

      np_houid = nonprofit_user.roles.where(host_type: "Nonprofit").first&.host&.houid
      expect(response).to redirect_to controller: "api_new/object_events", action: "index", nonprofit_id: np_houid
    end

    it "passes query params" do
      sign_in nonprofit_user
      get current_nonprofit_object_events_api_new_users_path({foo: "bar", baz: "qux"})

      np_houid = nonprofit_user.roles.where(host_type: "Nonprofit").first&.host&.houid
      expect(response).to redirect_to controller: "api_new/object_events", action: "index", nonprofit_id: np_houid, foo: "bar", baz: "qux"
    end

    it "returns a 404 not found when user doesn't have a nonprofit" do
      sign_in no_nonprofit_user
      get current_nonprofit_object_events_api_new_users_path

      expect(response).to have_http_status(:not_found)
    end
  end
end
