# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Nonprofits::TagMastersController, type: :request do
  let(:nonprofit) { create(:nonprofit_base) }

  before do
    sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
  end

  describe "#create" do
    it "creates a tag" do
      expect do
        post nonprofits_tag_masters_path(nonprofit_id: nonprofit.id),
          params: {tag_master: {name: "KQRS"}, format: :json}
      end.to change { nonprofit.tag_masters.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("KQRS")
    end

    it "rejects a duplicate name" do
      create(:tag_master_base, nonprofit: nonprofit, name: "KQRS")

      expect do
        post nonprofits_tag_masters_path(nonprofit_id: nonprofit.id),
          params: {tag_master: {name: "KQRS"}, format: :json}
      end.not_to change { nonprofit.tag_masters.count }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to eq('["Duplicate tag"]')
    end

    it "rejects a blank name" do
      post nonprofits_tag_masters_path(nonprofit_id: nonprofit.id),
        params: {tag_master: {name: ""}, format: :json}

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
