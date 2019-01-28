# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Campaigns::CampaignGiftOptionsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'accept all' do
      describe 'index' do
          include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, campaign_id: :__our_campaign
      end
    end
  end
end