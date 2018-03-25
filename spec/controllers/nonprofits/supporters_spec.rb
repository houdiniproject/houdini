require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::SupportersController, :type => :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'index' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end

    describe 'index_metrics' do
      include_context :open_to_np_associate, :get, :index_metrics, nonprofit_id: :__our_np
    end

    describe 'show' do
      include_context :open_to_np_associate, :get, :show, nonprofit_id: :__our_np
    end

    describe 'email_address' do
      include_context :open_to_np_associate, :get, :email_address, nonprofit_id: :__our_np
    end

    describe 'full_contact' do
      include_context :open_to_np_associate, :get, :full_contact, nonprofit_id: :__our_np
    end

    describe 'info_card' do
      include_context :open_to_np_associate, :get, :info_card, nonprofit_id: :__our_np
    end

    describe 'update' do
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np
    end

    describe 'bulk_delete' do
      include_context :open_to_np_associate, :delete, :bulk_delete, nonprofit_id: :__our_np
    end

    describe 'merge' do
      include_context :open_to_np_associate, :delete, :bulk_delete, nonprofit_id: :__our_np
    end
  end

  describe 'accept all users' do
    describe 'create' do
      include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
    end
  end
end