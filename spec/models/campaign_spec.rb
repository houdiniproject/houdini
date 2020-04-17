# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'sends correct email based on type of campaign' do
    let(:nonprofit) { force_create(:nm_justice) }
    let(:parent_campaign) { force_create(:campaign, name: 'Parent campaign', nonprofit: nonprofit) }
    let(:child_campaign) do
      force_create(:campaign,
                   name: 'Child campaign',
                   parent_campaign_id: parent_campaign.id,
                   slug: 'twehotiheiotheiofnieoth',
                   goal_amount_dollars: '1000', nonprofit: nonprofit)
    end

    it 'parent campaign sends out a create job' do
      expect(HoudiniEventPublisher).to receive(:announce).with(:campaign_create, any_args).exactly(:once)
      parent_campaign
    end

    it 'child campaign sends out federated create job' do
       expect(HoudiniEventPublisher).to receive(:announce).with(:campaign_create, any_args).exactly(:twice)
      parent_campaign
      child_campaign
    end
  end
end
