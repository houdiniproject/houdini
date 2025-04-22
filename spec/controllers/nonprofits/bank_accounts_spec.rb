# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::BankAccountsController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "create" do
      include_context :open_to_np_admin, :post, :create, nonprofit_id: :__our_np
    end

    describe "confirmation" do
      include_context :open_to_np_admin, :get, :confirmation, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "confirm" do
      include_context :open_to_np_admin, :post, :confirm, nonprofit_id: :__our_np
    end

    describe "cancellation" do
      include_context :open_to_np_admin, :get, :cancellation, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "cancel" do
      include_context :open_to_np_admin, :post, :cancel, nonprofit_id: :__our_np
    end

    describe "resend_confirmation" do
      include_context :open_to_np_admin, :post, :resend_confirmation, nonprofit_id: :__our_np
    end
  end
end
