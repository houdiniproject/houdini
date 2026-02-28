# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
  end
end
