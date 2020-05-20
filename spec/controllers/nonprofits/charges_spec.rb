# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Nonprofits::ChargesController, type: :controller do
  include_context :shared_user_context
  describe 'rejects unauthenticated users' do
    describe 'get' do
      include_context :open_to_np_associate, :get, :index, nonprofit_id: :__our_np
    end
  end
end
