# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::CampaignCreationFollowupJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      expect(CampaignMailer).to receive(:creation_followup).with(1).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::CampaignCreationFollowupJob.new(1)
      job.perform
    end
  end
end
