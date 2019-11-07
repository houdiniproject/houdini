class RefundNotificationNonprofitEmailJob < ApplicationJob
  queue_as :default

  def perform(refund)
    NonprofitMailer.refund_notification(refund.id).deliver_now
  end
end
