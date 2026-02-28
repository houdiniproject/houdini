# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Api::RolesController do
  describe "GET /api/nonprofits/:id/roles" do
    context "when nonprofit doesn't exists", pending: "the user gets a 401 but it's should be 404" do
      before do
        get "/api/nonprofits/1414140o/roles"
      end

      it {
        expect(response).to have_http_status(:not_found)
      }
    end

    context "when not logged in" do
      before do
        get "/api/nonprofits/#{create(:fv_poverty).id}"
      end

      it {
        expect(response).to have_http_status(:unauthorized)
      }

      it {
        expect(response).to have_attributes(content_type: starting_with("application/json"))
      }
    end

    context "when logged in" do
      subject do
        response.parsed_body
      end

      let(:user) { create(:user) }
      let(:nonprofit) { create(:fv_poverty) }
      let(:role) { user.roles.create(name: "nonprofit_associate", host: nonprofit) }

      before do
        role
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/roles"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(response).to have_attributes(content_type: starting_with("application/json"))
      }

      context "with response" do
        it {
          is_expected.to include_json(
            data: [
              {
                id: role.id,
                name: role.name,
                user_id: role.user.id,
                host: "Nonprofit",
                object: "role"
              }
            ]
          )
        }
      end
    end
  end
end
