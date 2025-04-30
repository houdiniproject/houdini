# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::ReportsController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "end_of_year" do
      include_context :open_to_np_associate, :get, :end_of_year, nonprofit_id: :__our_np
    end

    describe "end_of_year_custom" do
      include_context :open_to_np_associate, :get, :end_of_year_custom, nonprofit_id: :__our_np
    end
  end
end
