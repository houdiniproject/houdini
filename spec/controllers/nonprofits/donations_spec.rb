# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"
require "controllers/support/new_controller_user_context"
require "support/contexts/shared_donation_charge_context"

describe Nonprofits::DonationsController, type: :controller do
  describe "rejects unauthenticated users" do
    describe "index" do
      include_context :shared_user_context
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, id: "1"
    end

    describe "update" do
      include_context :shared_user_context
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np, id: "1"
    end
  end
  describe "accept all users" do
    describe "create" do
      include_context :open_to_all, :get, :create, nonprofit_id: :__our_np
    end
  end

  describe "followup" do
    include_context :shared_user_context
    include_context :open_to_np_associate, :put, :followup, nonprofit_id: :__our_np, id: "1"
  end

  describe "insecure direct object reference protection" do
    include_context :shared_user_context

    let(:other_np_supporter) { create(:supporter, nonprofit: other_nonprofit) }
    let(:other_np_donation) {
      create(:donation,
        supporter: other_np_supporter,
        nonprofit: other_nonprofit,
        amount: 1000)
    }

    describe "update" do
      it "prevents admin from updating donation belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          put :update, params: {nonprofit_id: nonprofit.id,
                                id: other_np_donation.id,
                                donation: {designation: "broken"}}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "followup" do
      it "prevents admin from updating donation belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          put :followup, params: {nonprofit_id: nonprofit.id,
                                  id: other_np_donation.id,
                                  donation: {designation: "broken"}}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

describe "Nonprofits::DonationsController::create_offsite", type: :request do
  describe "create_offsite" do
    include_context :shared_donation_charge_context
    include_context :new_controller_user_context

    it "reject non-campaign editors (and np authorized folks)" do
      run_authorization_tests({method: :post, action: "/nonprofits/#{nonprofit.id}/donations/create_offsite",
                               successful_users:  roles__open_to_campaign_editor}) do |_|
        {params: {nonprofit_id: nonprofit.id,
                  donation: {campaign_id: campaign.id}}}
      end
    end
    # include_context :open_to_np_associate, :post, :create_offsite, nonprofit_id: :__our_np
  end
end
