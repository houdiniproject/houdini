class RefundNotificationNonprofitEmailJob < EmailJob
  def perform(refund)
    NonprofitMailer.refund_notification(refund.id).deliver_now
  end
end
