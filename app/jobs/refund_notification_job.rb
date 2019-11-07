class RefundNotificationJob < ApplicationJob
  queue_as :default

  def perform(refund)
    RefundNotificationDonorEmailJob.perform_later(refund)
    RefundNotificationNonprofitEmailJob.perform_later(refund)
  end
end
