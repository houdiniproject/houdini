class PaymentNotificationEmailDonorJob < EmailJob
  def perform(donation, locale)
    DonationMailer.donor_payment_notification(donation.id, locale).deliver_now
  end
end
