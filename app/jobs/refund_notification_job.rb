class RefundNotificationJob < EmailJob
  def perform(refund)
    RefundNotificationDonorEmailJob.perform_later(refund)
    RefundNotificationNonprofitEmailJob.perform_later(refund)
  end
end
