# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::PaymentsController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'get payments' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'export payments' do
      include_context :open_to_np_associate, :get, :export, nonprofit_id: :__our_np
    end

    describe 'show payments' do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np, id: '1'
    end

    describe 'update' do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np, id: '1'
    end

    describe 'destroy payment' do
      include_context :open_to_np_associate, :delete, :destroy, nonprofit_id: :__our_np, id: '1'
    end
  end
end