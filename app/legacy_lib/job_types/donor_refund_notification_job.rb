# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DonorRefundNotificationJob < EmailJob
    attr_reader :refund_id
    def initialize(refund_id)
      @refund_id = refund_id
    end

    def perform
      UserMailer.refund_receipt(@refund_id).deliver
    end
  end
end
