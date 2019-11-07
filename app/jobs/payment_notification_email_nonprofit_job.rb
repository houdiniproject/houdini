class PaymentNotificationEmailNonprofitJob < ApplicationJob
  queue_as :default

  def perform(donation, user=nil)
    DonationMailer.nonprofit_payment_notification(donation.id, user&.id).deliver_now
  end
end
