# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require "rails_helper"

describe Users::SessionsController do
  describe "POST /users/sign_in" do
    context "with successful login" do
      let(:user) { create(:user) }
      let(:json) { response.parsed_body }

      before do
        post "/users/sign_in", params: {user: {email: user.email, password: user.password}}
      end

      it {
        expect(response).to have_http_status(:ok)
      }

      it {
        expect(response).to have_attributes(content_type: starting_with("application/json"))
      }

      it {
        expect(json).to eq({
          "id" => user.id,
          "object" => "user",
          "roles" => []
        })
      }
    end
  end
end
