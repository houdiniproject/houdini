# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::CampaignUpdatedJob do
  describe ".perform" do
    let(:parent_campaign) { create(:campaign_with_things_set_1, summary: "a new summary") }

    let!(:child_campaign) {
      create(:campaign_with_things_set_1,
        nonprofit_id: parent_campaign.nonprofit.id,
        parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-1")
    }

    let!(:child_campaign_2) {
      create(:campaign_with_things_set_1,
        nonprofit_id: parent_campaign.nonprofit.id,
        parent_campaign_id: parent_campaign.id, slug: "another-slug-of-slugs-2")
    }

    it "schedules the child campaigns to update" do
      expect_job_queued.with(JobTypes::ChildCampaignUpdateJob, child_campaign.id)
      expect_job_queued.with(JobTypes::ChildCampaignUpdateJob, child_campaign_2.id)

      job = JobTypes::CampaignUpdatedJob.new(parent_campaign.id)
      job.perform
    end
  end
end
