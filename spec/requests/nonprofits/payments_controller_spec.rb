# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Nonprofits::PaymentsController, type: :request do
  describe "#index" do
    let(:user) { create(:user_as_nonprofit_associate) }
    let(:nonprofit) { user.roles.first.host }

    it "loads properly" do
      sign_in user

      get "/nonprofits/#{nonprofit.id}/payments"

      expect(@response).to have_http_status(:success)
    end
  end
end
