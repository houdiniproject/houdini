# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::PayoutsController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'create' do
      include_context :open_to_np_admin, :post, :create, nonprofit_id: :__our_np
    end

    describe 'index' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'show' do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np, id: '1'
    end


  end
end