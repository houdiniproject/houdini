require 'rails_helper'
require 'controllers/support/shared_user_context'

describe SettingsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'index' do
        include_context :open_to_registered, :get, :index, nonprofit_id: :__our_np
      end
    end
  end
end