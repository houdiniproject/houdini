# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe BillingSubscriptionsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context

    describe "cancel" do
      include_context :open_to_np_admin, :post, :cancel, nonprofit_id: :__our_np
    end

    describe "cancellation" do
      include_context :open_to_np_admin, :get, :cancellation, nonprofit_id: :__our_np, without_json_view: true
    end
  end
end
