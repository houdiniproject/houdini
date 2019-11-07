class RefundNotificationJob < ApplicationJob
  queue_as :default

  def perform(refund)
    RefundNotificationJobDonorEmail.perform_later(refund)
    RefundNotificationJobNonprofitEmail.perform_later(refund)
  end
end
