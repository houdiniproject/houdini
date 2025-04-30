# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::TicketMailerReceiptAdminJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      expect(TicketMailer).to receive(:receipt_admin).with(1, 2).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::TicketMailerReceiptAdminJob.new(1, 2)
      job.perform
    end
  end
end
