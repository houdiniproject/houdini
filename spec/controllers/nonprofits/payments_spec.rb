# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::PaymentsController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "get payments" do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "export payments" do
      include_context :open_to_np_associate, :get, :export, nonprofit_id: :__our_np
    end

    describe "show payments" do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np, id: "1", with_status: 200
    end

    describe "update" do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np, id: "1"
    end

    describe "destroy payment" do
      include_context :open_to_np_associate, :delete, :destroy, nonprofit_id: :__our_np, id: "1"
    end

    describe "resend_donor_receipt" do
      include_context :open_to_np_associate, :post, :resend_donor_receipt, nonprofit_id: :__our_np, id: "1"
    end

    describe "resend_admin_receipt" do
      include_context :open_to_np_associate, :post, :resend_admin_receipt, nonprofit_id: :__our_np, id: "1"
    end
  end

  describe "insecure direct object reference protection" do
    let(:other_np_supporter) { create(:supporter, nonprofit: other_nonprofit) }
    let(:other_np_payment) {
      create(:payment,
        supporter: other_np_supporter,
        nonprofit: other_nonprofit,
        gross_amount: 1000)
    }

    describe "resend_donor_receipt" do
      it "prevents triggering receipt for payment belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          post :resend_donor_receipt, params: {nonprofit_id: nonprofit.id,
                                               id: other_np_payment.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "resend_admin_receipt" do
      it "prevents triggering receipt for payment belonging to another nonprofit" do
        sign_in user_as_np_admin
        expect do
          post :resend_admin_receipt, params: {nonprofit_id: nonprofit.id,
                                               id: other_np_payment.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
