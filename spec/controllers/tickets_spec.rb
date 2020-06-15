# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe TicketsController, type: :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'index' do
        include_context :open_to_event_editor, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event, without_json_view: true
      end

      describe 'update' do
        include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event, id: 1111
      end

      describe 'destroy' do
        include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event, id: 1111
      end

      describe 'delete_card_for_ticket' do
        include_context :open_to_np_associate, :post, :delete_card_for_ticket, nonprofit_id: :__our_np, event_id: :__our_event, id: 11_111
      end
    end

    describe 'open to all' do
      describe 'create' do
        include_context :open_to_all, :post, :create, nonprofit_id: :__our_np, event_id: :__our_event
      end

      describe 'add_note' do
        include_context :open_to_all, :put, :add_note, nonprofit_id: :__our_np, event_id: :__our_event, id: 1111
      end
    end
  end
end
