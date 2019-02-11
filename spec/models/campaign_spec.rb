# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'sends correct email based on type of campaign' do
    let(:nonprofit) { force_create(:nonprofit)}
    let(:parent_campaign) { force_create(:campaign, name: 'Parent campaign', nonprofit: nonprofit) }
    let(:child_campaign) do
      force_create(:campaign,
                   name: 'Child campaign',
                   parent_campaign_id: parent_campaign.id,
                   slug: "twehotiheiotheiofnieoth",
                   goal_amount_dollars: "1000", nonprofit: nonprofit )
    end

    it 'parent campaign sends out general campaign email' do
      expect { parent_campaign }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.last.body.include?("Create one-time or recurring")).to be_truthy
    end

    it 'child campaign sends out federated campaign email' do
      expect { child_campaign}.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(ActionMailer::Base.deliveries.last.body.include?("including a testimonial")).to be_truthy
    end
  end
end
