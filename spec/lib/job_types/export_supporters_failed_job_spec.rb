require "rails_helper"

describe JobTypes::ExportSupportersFailedJob do
  describe ".perform" do
    it "calls the correct active mailer" do
      input = 1
      expect(ExportMailer).to receive(:export_supporters_failed_notification).with(input).and_wrap_original { |m, *args|
        mailer = double("object")
        expect(mailer).to receive(:deliver).and_return(nil)
        mailer
      }

      job = JobTypes::ExportSupportersFailedJob.new(input)
      job.perform
    end
  end
end
