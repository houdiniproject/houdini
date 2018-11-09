# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::CustomFieldJoinsController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'index ' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'modify' do
      include_context :open_to_np_associate, :post, :modify, nonprofit_id: :__our_np, id: "1"
    end

    describe 'destroy' do
      include_context :open_to_np_associate, :delete, :destroy, nonprofit_id: :__our_np, id: "1"
    end
  end
end