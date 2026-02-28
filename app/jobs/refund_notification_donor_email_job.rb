class RefundNotificationDonorEmailJob < EmailJob
  def perform(refund)
    UserMailer.refund_receipt(refund).deliver_now
  end
end
