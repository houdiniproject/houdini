# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::TrackingsController, type: :controller do
  include_context :shared_user_context
  describe "open to all" do
    describe "create" do
      include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
    end
  end
end
