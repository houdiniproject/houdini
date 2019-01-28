# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe TicketsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'update' do
          include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event
      end
      describe 'index' do
          include_context :open_to_event_editor, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event
      end


      describe 'destroy' do
          include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event
      end

      describe 'delete_card_for_ticket' do
          include_context :open_to_np_associate, :post, :delete_card_for_ticket, nonprofit_id: :__our_np, event_id: :__our_event, id: 11111
      end


    end

    describe 'open to all' do
      describe 'create' do
          include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
      end

      describe 'add_note' do
        include_context :open_to_all, :put, :add_note, nonprofit_id: :__our_np, event_id: :__our_event
      end

    end
  end
end