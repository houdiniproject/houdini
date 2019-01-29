# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'
require 'controllers/support/new_controller_user_context'
require 'support/contexts/shared_donation_charge_context'

describe Nonprofits::DonationsController, :type => :controller do

  describe 'rejects unauthenticated users' do
    describe 'index' do
      include_context :shared_user_context
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, id: "1"
    end



    describe 'update' do
      include_context :shared_user_context
      include_context :open_to_np_associate, :put, :update, nonprofit_id: :__our_np, id: "1"
    end


  end
  describe 'accept all users' do
    describe 'create' do
      include_context :open_to_all, :get, :create, nonprofit_id: :__our_np
    end

    describe 'follow up' do
      include_context :open_to_all, :put, :followup, nonprofit_id: :__our_np, id: "1"
    end
  end
end

describe '.create_offsite', :type => :request do
  describe 'create_offsite' do
    include_context :shared_donation_charge_context
    include_context :general_shared_user_context
    require 'support/contexts/general_shared_user_context.rb'

    # it 'reject non-campaign editors (and np authorized folks)', :type => :request do
    #   run_authorization_tests({method: :post, action: "/nonprofits/#{nonprofit.id}/donations/create_offsite",
    #                            successful_users:  roles__open_to_campaign_editor}) do |_|
    #     {nonprofit_id: nonprofit.id,
    #      donation: {campaign_id: campaign.id}}
    #   end
    # end
    #include_context :open_to_np_associate, :post, :create_offsite, nonprofit_id: :__our_np
  end
end