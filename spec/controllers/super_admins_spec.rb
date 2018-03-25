require 'rails_helper'
require 'controllers/support/shared_user_context'

describe SuperAdminsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'search_nonprofits' do
          include_context :open_to_super_admin, :get, :search_nonprofits
      end

      describe 'search_profiles' do
          include_context :open_to_super_admin, :get, :search_profiles
      end

      describe 'search_fullcontact' do
          include_context :open_to_super_admin, :get, :search_fullcontact
      end

      describe 'index' do
          include_context :open_to_super_admin, :get, :index
      end
      
      
    end
  end
end