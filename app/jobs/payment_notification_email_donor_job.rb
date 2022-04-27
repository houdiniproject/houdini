class PaymentNotificationEmailDonorJob < EmailJob

  def perform(donation)
    DonationMailer.donor_payment_notification(donation.id).deliver_now
  end
end
