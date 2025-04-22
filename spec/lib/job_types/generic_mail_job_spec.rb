# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::GenericMailJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      expect(GenericMailer).to receive(:generic_mail).with(1, 2, 3, 4, 5, 6).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::GenericMailJob.new(1, 2, 3, 4, 5, 6)
      job.perform
    end
  end
end
