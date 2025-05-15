# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::NonprofitAdminNewInviteJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      expect(NonprofitAdminMailer).to receive(:new_invite).with(1, 2).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::NonprofitAdminNewInviteJob.new(1, 2)
      job.perform
    end
  end
end
