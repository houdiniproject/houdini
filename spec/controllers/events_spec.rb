# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe EventsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'create' do
        include_context :open_to_event_editor, :post, :create, nonprofit_id: :__our_np, id: :__our_event
    end
    describe 'update' do
        include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, id: :__our_event
    end
    describe 'duplicate' do
        include_context :open_to_event_editor, :post, :duplicate, nonprofit_id: :__our_np, id: :__our_event
    end
    describe 'soft_delete' do
        include_context :open_to_event_editor, :delete, :soft_delete, nonprofit_id: :__our_np, event_id: :__our_event
    end
    describe 'stats' do
        include_context :open_to_event_editor, :get, :stats, nonprofit_id: :__our_np, id: :__our_event
    end

    describe 'name_and_id' do
        include_context :open_to_np_associate, :get, :name_and_id, nonprofit_id: :__our_np
    end
  end

  describe 'open to all' do
    describe 'index' do
        include_context :open_to_all, :get, :index, nonprofit_id: :__our_np
    end

    describe 'listings' do
        include_context :open_to_all, :get, :listings, nonprofit_id: :__our_np
    end

    describe 'show' do
        include_context :open_to_all, :get, :show, nonprofit_id: :__our_np, id: :__our_event
    end

    describe 'activities' do
        include_context :open_to_all, :get, :activities, nonprofit_id: :__our_np, id: :__our_event
    end
    describe 'metrics' do
        include_context :open_to_all, :get, :metrics, nonprofit_id: :__our_np, id: :__our_event
    end



  end

end