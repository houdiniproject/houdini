# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Campaigns::SupportersController, type: :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'reject unauthorized' do
      describe 'index' do
        include_context :open_to_campaign_editor, :get, :index, nonprofit_id: :__our_np, campaign_id: :__our_campaign, without_json_view: true
      end
    end
  end
end
