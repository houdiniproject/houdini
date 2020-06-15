# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe ProfilesController, type: :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'update' do
        include_context :open_to_profile_owner, :put, :update, id: :__our_profile
      end

      describe 'fundraisers' do
        include_context :open_to_profile_owner, :get, :fundraisers, id: :__our_profile, without_json_view: true
      end

      describe 'donations_history' do
        include_context :open_to_profile_owner, :get, :donations_history, id: :__our_profile, without_json_view: true
      end
    end

    describe 'open to all' do
      describe 'show' do
        include_context :open_to_all, :get, :show, id: :__our_np, without_json_view: true
      end
    end
  end
end
