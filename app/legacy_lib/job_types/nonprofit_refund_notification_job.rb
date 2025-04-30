# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitRefundNotificationJob < EmailJob
    attr_reader :refund_id, :user_id
    def initialize(refund_id, user_id = nil)
      @refund_id = refund_id
      @user_id = user_id
    end

    def perform
      NonprofitMailer.refund_notification(@refund_id, @user_id).deliver
    end
  end
end
