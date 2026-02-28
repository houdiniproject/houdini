# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"
# rubocop:disable RSpec/InstanceVariable
describe "Maintenance Mode" do
  page = "http://commet"
  token = "thoathioa"
  include_context :shared_user_context

  describe SettingsController, type: :controller do
    describe "(Settings is just a basic example controller)"
    it "not in maintenance mode" do
      get :index
      expect(response).to have_http_status(:found)
    end

    describe "in maintenance" do
      before do
        Houdini.maintenance = Houdini::Maintenance.new(active: true, token: token, page: page)
      end

      it "redirects for settings" do
        get :index
        expect(response).to have_attributes(code: "302", location: page)
      end

      it "allows access to non-sign_in pages if youre logged in" do
        sign_in user_as_np_associate
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe Users::SessionsController, type: :controller do
    after do
      Houdini.maintenance.active = false
    end

    describe "in maintenance" do
      include_context :shared_user_context

      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      describe "in maintenance" do
        before do
          Houdini.maintenance = Houdini::Maintenance.new(active: true, token: token, page: page)
        end

        describe "redirects sign_in if the token is wrong" do
          subject do
            get(:new, params: {maintenance_token: "#{token}3"})
            response
          end

          it { is_expected.to have_attributes(code: "302", location: page) }
        end

        describe "redirects to sign_in" do
          subject do
            get(:new)
            response
          end

          it { is_expected.to have_attributes(code: "302", location: page) }
        end

        describe "redirects to sign_in if token passed on wrong param" do
          subject do
            get(:new, params: {maintnancerwrwer_token: token.to_s})
            response
          end

          it { is_expected.to have_attributes(code: "302", location: page) }
        end

        describe "allows sign_in if the token is passed" do
          subject do
            get(:new, params: {maintenance_token: token.to_s})
            response
          end

          it { is_expected.to have_attributes(code: "200") }
        end

        describe "allows sign_in.json if the token is passed" do
          subject do
            get(:new, params: {maintenance_token: token.to_s, format: "json"})
            response
          end

          it { is_expected.to have_attributes(code: "200") }
        end
      end
    end

    describe "in maintenance without maintenance_token set" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        Houdini.maintenance = Houdini::Maintenance.new(active: true, token: nil, page: page)
      end

      describe "redirects sign_in if the token is nil" do
        subject do
          get(:new)
          response
        end

        it { is_expected.to have_attributes(code: "302", location: page) }
      end
    end
  end
end

# rubocop:enable all
