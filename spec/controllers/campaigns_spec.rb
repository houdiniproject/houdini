# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe CampaignsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'create' do
        include_context :open_to_confirmed_users, :post, :create, nonprofit_id: :__our_np
      end

      describe 'name_and_id' do
        include_context :open_to_confirmed_users, :get, :name_and_id, nonprofit_id: :__our_np
      end

      describe 'duplicate' do
        include_context :open_to_confirmed_users, :post, :duplicate, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'update' do
          include_context :open_to_campaign_editor, :put, :update, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'soft_delete' do
          include_context :open_to_campaign_editor, :delete, :soft_delete, nonprofit_id: :__our_np, id: :__our_campaign
      end

    end
    describe 'open to all' do
      describe 'index' do
          include_context :open_to_all, :get, :index, nonprofit_id: :__our_np
      end

      describe 'show' do
          include_context :open_to_all, :get, :show, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'activities' do
          include_context :open_to_all, :get, :activities, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'metrics' do
          include_context :open_to_all, :get, :metrics, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'timeline' do
          include_context :open_to_all, :get, :timeline, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'totals' do
          include_context :open_to_all, :get, :totals, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe 'peer_to_peer' do
          include_context :open_to_all, :get, :peer_to_peer, nonprofit_id: :__our_np
      end
    end
  end

  describe 'routes' do
    it "routes campaigns#index" do
      expect(:get => "/nonprofits/5/campaigns/4").to(route_to(:controller => "campaigns", :action => "show", nonprofit_id: "5", id: "4"))
    end
  end
end