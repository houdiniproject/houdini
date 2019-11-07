class PaymentNotificationJob < ApplicationJob
  queue_as :default

  def perform(donation, locale)
    PaymentNotificationEmailDonorJob.perform_later donation, locale
    PaymentNotificaitonEmailNonprofitJob.
  end
end
