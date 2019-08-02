# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitRefundNotificationJob < EmailJob
    attr_reader :refund_id
    def initialize(refund_id)
      @refund_id = refund_id
    end

    def perform
      NonprofitMailer.refund_notification(@refund_id).deliver
    end
  end
end
