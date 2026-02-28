# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::MiscellaneousNpInfosController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "show" do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np
    end

    describe "update" do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np
    end
  end
end
