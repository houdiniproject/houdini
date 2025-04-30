# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Users::SessionsController, type: :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  describe "#create" do
    describe "basic auth" do
      it "accepts a correct password" do
        user = create(:user, :confirmed)

        post :create, params: {user: {email: user.email, password: user.password}}, format: :json

        expect(response).to have_http_status(200)
      end

      it "rejects an invalid password" do
        user = create(:user, :confirmed)

        post :create, params: {user: {email: user.email, password: "not valid"}}, format: :json

        expect(response).to have_http_status(401)
      end

      it "throw an error if format is not :json" do
        user = create(:user, :confirmed)

        expect do
          post :create, params: {user: {email: user.email, password: user.password}}
        end.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
