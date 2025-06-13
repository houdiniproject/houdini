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

      it "returns auth failed when user param is missing" do
        post :create, params: {}, format: :json
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(["Authentication failed"])
      end

      it "returns auth failed when user does not exist" do
        post :create, params: {user: {email: "nonexistent@example.com", password: "password"}}, format: :json
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(["Authentication failed"])
      end

      it "signs in user and returns success when OTP is not required" do
        user = create(:user, :confirmed, otp_required_for_login: false)
        post :create, params: {user: {email: user.email, password: user.password}}, format: :json

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"status" => "Success"})
        expect(controller.current_user).to eq(user)
      end
    end

    describe "OTP authentication" do
      let(:user) { create(:user, :confirmed, otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      it "returns otp_required status when OTP is required but not provided" do
        post :create, params: {user: {email: user.email, password: user.password}}, format: :json

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"status" => "otp_required"})
        expect(controller.current_user).to be_nil
      end

      it "signs in user with valid OTP" do
        valid_otp = user.current_otp
        post :create, params: {user: {email: user.email, password: user.password, otp_attempt: valid_otp}},
          format: :json

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"status" => "Success"})
        expect(controller.current_user).to eq(user)
      end

      it "succeeds even when user is not confirmed" do
        user = create(:user, otp_required_for_login: true, otp_secret: User.generate_otp_secret, confirmed_at: nil)
        valid_otp = user.current_otp

        post :create, params: {user: {email: user.email, password: user.password, otp_attempt: valid_otp}},
          format: :json

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"status" => "Success"})
        expect(controller.current_user).to eq(user)
      end

      it "returns auth failed with invalid OTP" do
        post :create, params: {user: {email: user.email, password: user.password, otp_attempt: "123456"}},
          format: :json

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(["Authentication failed"])
        expect(controller.current_user).to be_nil
      end

      it "returns auth failed when email is invalid even with valid OTP" do
        valid_otp = user.current_otp
        post :create, params: {user: {email: "nonexistent@example.com", password: user.password, otp_attempt: valid_otp}},
          format: :json

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(["Authentication failed"])
        expect(controller.current_user).to be_nil
      end

      it "returns auth failed when password is invalid even with valid OTP" do
        valid_otp = user.current_otp
        post :create, params: {user: {email: user.email, password: "wrong_password", otp_attempt: valid_otp}},
          format: :json

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(["Authentication failed"])
        expect(controller.current_user).to be_nil
      end

      it "returns auth failed when user is locked" do
        user = create(:user, :confirmed, otp_required_for_login: true, otp_secret: User.generate_otp_secret, locked_at: Time.current)
        valid_otp = user.current_otp

        post :create, params: {user: {email: user.email, password: user.password, otp_attempt: valid_otp}},
          format: :json

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)).to eq(
          {"error" => "Your account has been locked due to too many sign in attempts."}
        )
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe "#send_otp" do
    it "sends OTP email for user with OTP enabled" do
      user = create(:user, :confirmed, otp_required_for_login: true)

      expect(UserMailer).to receive(:otp_requested).with(user).and_return(double(deliver_later: true))

      post :send_otp, params: {email: user.email, password: user.password}, format: :json

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq({"status" => "success"})
    end

    it "returns 401 for non-existent user" do
      post :send_otp, params: {email: "nonexistent@example.com", password: "nonexistent"}, format: :json

      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)).to eq(["Authentication failed"])
    end

    it "returns 401 for wrong password" do
      user = create(:user, :confirmed, otp_required_for_login: true)

      post :send_otp, params: {email: user.email, password: "wrong_password"}, format: :json

      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)).to eq(["Authentication failed"])
    end

    it "returns 422 when OTP is not required for user" do
      user = create(:user, :confirmed, otp_required_for_login: false)

      post :send_otp, params: {email: user.email, password: user.password}, format: :json

      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)).to eq(["OTP not required"])
    end
  end
end
