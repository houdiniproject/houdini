# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::NonprofitPaymentNotificationJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      expect(DonationMailer).to receive(:nonprofit_payment_notification).with(1, 2, nil).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::NonprofitPaymentNotificationJob.new(1, 2)
      job.perform
    end

    it "calls the correct active mailer, with user id" do
      expect(DonationMailer).to receive(:nonprofit_payment_notification).with(1, 2, 3).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::NonprofitPaymentNotificationJob.new(1, 2, 3)
      job.perform
    end
  end
end
