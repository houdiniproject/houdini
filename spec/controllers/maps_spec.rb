# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe MapsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "all_supporters" do
        include_context :open_to_super_admin, :get, :all_supporters, with_status: 200
      end

      describe "all_npo_supporters" do
        include_context :open_to_np_associate, :get, :all_npo_supporters, nonprofit_id: :__our_np, with_status: 200
      end

      describe "specific_npo_supporters" do
        include_context :open_to_np_associate, :get, :specific_npo_supporters, nonprofit_id: :__our_np, with_status: 200
      end
    end

    describe "open_to_all" do
      describe "all_npos" do
        include_context :open_to_all, :get, :all_npos, nonprofit_id: :__our_np, with_status: 200
      end
    end
  end
end
