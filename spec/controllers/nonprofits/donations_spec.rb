require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::DonationsController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'index' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'create_offsite' do
      include_context :open_to_np_associate, :post, :create_offsite, nonprofit_id: :__our_np
    end

    describe 'update' do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np
    end


  end
  describe 'accept all users' do
    describe 'create' do
      include_context :open_to_all, :get, :create, nonprofit_id: :__our_np
    end

    describe 'follow up' do
      include_context :open_to_all, :put, :followup, nonprofit_id: :__our_np
    end
  end
end