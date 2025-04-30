# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe Nonprofits::ButtonController, type: :controller do
  include_context :shared_user_context
  describe "rejects unauthenticated users" do
    describe "send_code" do
      include_context :open_to_registered, :get, :send_code, nonprofit_id: :__our_np
    end

    describe "basic" do
      include_context :open_to_registered, :get, :basic, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "guided" do
      include_context :open_to_registered, :get, :guided, nonprofit_id: :__our_np, without_json_view: true
    end

    describe "advanced" do
      include_context :open_to_registered, :get, :advanced, nonprofit_id: :__our_np, without_json_view: true
    end
  end
end
