# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::ChildCampaignUpdateJob do
  describe ".perform" do
    let(:parent_campaign) { create(:campaign_with_things_set_1, summary: "a new summary") }

    let!(:child_campaign) {
      create(:campaign_with_things_set_1,
        nonprofit_id: parent_campaign.nonprofit.id,
        parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-1")
    }

    it "updates the child from the parent" do
      job = JobTypes::ChildCampaignUpdateJob.new(child_campaign.id)
      job.perform

      child_campaign.reload

      expect(child_campaign.summary).to eq "a new summary"
    end
  end
end
