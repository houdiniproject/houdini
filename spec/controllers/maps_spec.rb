# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe MapsController, type: :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'all_supporters' do
        include_context :open_to_super_admin, :get, :all_supporters, without_json_view: true
      end

      describe 'all_npo_supporters' do
        include_context :open_to_np_associate, :get, :all_npo_supporters, nonprofit_id: :__our_np, without_json_view: true
      end

      describe 'specific_npo_supporters' do
        include_context :open_to_np_associate, :get, :specific_npo_supporters, nonprofit_id: :__our_np, without_json_view: true
      end
    end

    describe 'open_to_all' do
      describe 'all_npos' do
        include_context :open_to_all, :get, :all_npos, nonprofit_id: :__our_np, without_json_view: true
      end
    end
  end
end
