class RefundNotificationDonorEmailJob < ApplicationJob
  queue_as :default

  def perform(refund)
    UserMailer.refund_receipt(refund).deliver_now
  end
end
