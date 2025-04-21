# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe ImageAttachmentsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "create" do
        include_context :open_to_confirmed_users, :post, :create
      end

      describe "remove" do
        include_context :open_to_confirmed_users, :post, :remove
      end
    end
  end
end
