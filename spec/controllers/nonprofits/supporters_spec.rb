# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::SupportersController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "index" do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "index_metrics" do
      include_context :open_to_np_associate, :get, :index_metrics, nonprofit_id: :__our_np
    end

    describe "show" do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np, id: "1"
    end

    describe "email_address" do
      include_context :open_to_np_associate, :get, :email_address, nonprofit_id: :__our_np, id: "1"
    end

    describe "full_contact" do
      include_context :open_to_np_associate, :get, :full_contact, nonprofit_id: :__our_np, id: "1"
    end

    describe "info_card" do
      include_context :open_to_np_associate, :get, :info_card, nonprofit_id: :__our_np, id: "1"
    end

    describe "update" do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np, id: "1"
    end

    describe "bulk_delete" do
      include_context :open_to_np_associate, :delete, :bulk_delete, nonprofit_id: :__our_np
    end

    describe "merge" do
      include_context :open_to_np_associate, :delete, :bulk_delete, nonprofit_id: :__our_np
    end
  end

  describe "accept all users" do
    describe "create" do
      include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
    end
  end

  describe "insecure direct object reference protection" do
    let(:other_np_supporter) { create(:supporter, nonprofit: other_nonprofit) }

    describe "email_address" do
      it "prevents access to supporter belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          get :email_address, params: {nonprofit_id: nonprofit.id,
                                       id: other_np_supporter.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "full_contact" do
      it "prevents access to supporter belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          get :full_contact, params: {nonprofit_id: nonprofit.id,
                                      id: other_np_supporter.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "info_card" do
      it "prevents access to supporter belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          get :info_card, params: {nonprofit_id: nonprofit.id,
                                   id: other_np_supporter.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "merge_data" do
      it "filters out supporters belonging to another nonprofit" do
        our_supporter = create(:supporter, nonprofit: nonprofit)
        sign_in user_as_np_admin

        get :merge_data, params: {nonprofit_id: nonprofit.id,
                                  ids: [our_supporter.id, other_np_supporter.id]}

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        returned_ids = response_body.map { |s| s["id"] }
        expect(returned_ids).to include(our_supporter.id)
        expect(returned_ids).not_to include(other_np_supporter.id)
      end
    end
  end
end
