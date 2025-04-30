# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::RefundCreatedJob do
  describe ".perform" do
    let(:refund) { force_create(:refund) }
    let(:job) { JobTypes::RefundCreatedJob.new(refund).perform }

    it "sends refund notifications" do
      expect_job_queued.with(JobTypes::NonprofitRefundNotificationJob, refund.id)
      expect_job_queued.with(JobTypes::DonorRefundNotificationJob, refund.id)
      job
    end
  end
end
