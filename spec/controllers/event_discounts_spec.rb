# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe EventDiscountsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'create' do
          include_context :open_to_event_editor, :post, :create, nonprofit_id: :__our_np, event_id: :__our_event
      end
      
      describe 'update' do
          include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event, id: '2'
      end
      
      describe 'destroy' do
          include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event, id: '2'
      end
      
      
    end
    
    describe 'open to all' do
      describe 'index' do
          include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event, id: "2"
      end
    end
  end
end