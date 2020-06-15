# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::TagJoinsController, type: :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'index' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np, supporter_id: 1
    end

    describe 'modify' do
      include_context :open_to_np_associate, :post, :modify, nonprofit_id: :__our_np, id: '1'
    end

    describe 'destroy' do
      include_context :open_to_np_associate, :delete, :destroy, nonprofit_id: :__our_np, id: '1', supporter_id: 2
    end
  end
end
