class PaymentNotificationJob < ApplicationJob
  queue_as :default

  def perform(donation, locale, user=nil)
    PaymentNotificationEmailDonorJob.perform_later donation, locale
    PaymentNotificationEmailNonprofitJob.perform_later donation, user
  end
end
