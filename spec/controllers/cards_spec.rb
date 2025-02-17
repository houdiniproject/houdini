# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe CardsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "accept all" do
      describe "create" do
        include_context :open_to_all, :post, :create, nonprofit_id: :__our_np, with_status: 200
      end
    end
  end
end
