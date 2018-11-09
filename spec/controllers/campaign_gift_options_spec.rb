# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe CampaignGiftOptionsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'reject unauthorized' do
      describe 'create' do
        include_context :open_to_campaign_editor, :post, :create, nonprofit_id: :__our_np, campaign_id: :__our_campaign
      end

      describe 'update' do
        include_context :open_to_campaign_editor, :put, :update, nonprofit_id: :__our_np, campaign_id: :__our_campaign, id: "1"
      end
      describe 'destroy' do
        include_context :open_to_campaign_editor, :delete, :destroy, nonprofit_id: :__our_np, campaign_id: :__our_campaign, id: "1"
      end

      describe 'update_order' do
        include_context :open_to_campaign_editor, :put, :update_order, nonprofit_id: :__our_np, campaign_id: :__our_campaign, id: "1"
      end
    end

    describe 'accept all' do
      describe 'index' do
        include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, campaign_id: :__our_campaign
      end

      describe 'show' do
        include_context :open_to_all, :get, :show, nonprofit_id: :__our_np, campaign_id: :__our_campaign, id: "1"
      end
    end
  end
end