# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require "rails_helper"

describe Api::UsersController do
  describe "GET /api/users/current" do
    context "when not logged in" do
      before { get "/api/users/current" }

      it {
        expect(response).to have_http_status(:unauthorized)
      }

      it {
        expect(response).to have_attributes(content_type: starting_with("application/json"))
      }
    end

    context "when logged in" do
      before do
        sign_in create(:user)
        get "/api/users/current"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(response).to have_attributes(content_type: starting_with("application/json"))
      }

      it {
        expect(response.parsed_body["id"]).to be_a Numeric
      }
    end
  end
end
