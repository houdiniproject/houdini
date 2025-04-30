# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class RefundCreatedJob < GenericJob
    attr_reader :refund

    def initialize(refund)
      @refund = refund
    end

    def perform
      JobQueue.queue JobTypes::DonorRefundNotificationJob, refund.id
      JobQueue.queue JobTypes::NonprofitRefundNotificationJob, refund.id
    end
  end
end
