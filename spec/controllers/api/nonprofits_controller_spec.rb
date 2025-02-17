# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Api::NonprofitsController, type: :request do
  let(:user) { create(:user) }
  let(:nonprofit_admin_role) do
    role = user.roles.build(host: nonprofit, name: "nonprofit_admin")
    role.save!
    role
  end
  let(:nonprofit) { create(:nm_justice) }

  describe "get" do
  end

  describe "create" do
    around do |example|
      @old_bp = Houdini.default_bp
      example.run
      Houdini.default_bp = @old_bp
    end

    it "validates and returns correct errors" do
      input = {}
      post "/api/nonprofits", params: input, xhr: true
      expect(response).to have_http_status :unprocessable_entity
      expect(response.parsed_body["errors"].keys).to match_array %w[name city state_code slug user_id]
    end

    it "succeeds" do
      input = {name: "n", state_code: "WI", city: "appleton", zip_code: 54_915, user_id: user.id,
               phone: "920-555-5555"}
      sign_in user
      bp = force_create(:billing_plan)
      Houdini.default_bp = bp.id

      sign_in user

      post "/api/nonprofits", params: input, xhr: true
      expect(response).to have_http_status :created

      expected_np = {
        name: "n",
        state_code: "WI",
        city: "appleton",
        zip_code: "54915",
        state_code_slug: "wi",
        city_slug: "appleton",
        slug: "n",
        phone: "920-555-5555",
        email: nil,
        website: nil,
        urls: {plain_url: "http://www.example.com/nonprofits/1", slug_url: "http://www.example.com/wi/appleton/n"}
      }.with_indifferent_access

      expect(response.parsed_body["id"]).to be > 0
      expect(response.parsed_body.except("id")).to eq expected_np

      expect(Nonprofit.find(1).billing_plan).to_not be_nil
    end
  end
end
