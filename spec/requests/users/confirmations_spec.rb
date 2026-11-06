# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Users::ConfirmationsController, type: :request do
  describe "POST /confirm" do
    let(:user) { User.create!(email: "invited@example.com", auto_generated: true) }
    let!(:token) { user.make_confirmation_token! }

    def set_password(id: user.id, confirmation_token: token, password: "newpassword1")
      post "/confirm", params: {id: id, user: {confirmation_token: confirmation_token, password: password, password_confirmation: password}}
    end

    it "sets the password with the token from the confirmation email" do
      set_password

      expect(user.reload.valid_password?("newpassword1")).to be true
      expect(response).to redirect_to(root_url)
    end

    it "can't be used twice with the same token" do
      set_password
      set_password(password: "secondpassword1")

      expect(user.reload.valid_password?("secondpassword1")).to be false
    end

    it "rejects a request without a token" do
      set_password(confirmation_token: "")

      expect(user.reload.valid_password?("newpassword1")).to be false
    end

    it "rejects a token for a different user" do
      other = User.create!(email: "other@example.com", auto_generated: true)

      set_password(id: other.id)

      expect(other.reload.valid_password?("newpassword1")).to be false
      expect(user.reload.valid_password?("newpassword1")).to be false
    end

    it "rejects an account that already has its own password" do
      existing = create(:user, :confirmed)
      existing_token = existing.make_confirmation_token!

      set_password(id: existing.id, confirmation_token: existing_token)

      expect(existing.reload.valid_password?("newpassword1")).to be false
    end

    it "only changes the password" do
      post "/confirm", params: {id: user.id, user: {confirmation_token: token, password: "newpassword1", password_confirmation: "newpassword1", email: "taken-over@example.com"}}

      expect(user.reload.email).to eq "invited@example.com"
    end
  end

  describe "GET /users/exists" do
    it "is no longer routed" do
      recognized = begin
        Rails.application.routes.recognize_path("/users/exists", method: :get)
      rescue ActionController::RoutingError
        nil
      end

      expect(recognized || {}).not_to include(controller: "users/confirmations", action: "exists")
    end
  end
end
