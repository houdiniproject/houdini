class PaymentNotificationEmailDonorJob < ApplicationJob
  queue_as :default

  def perform(donation, locale)
    DonationMailer.donor_payment_notification(donation.id, locale).deliver_now
  end
end
