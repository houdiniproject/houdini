class AdminFailedGiftJob < ApplicationJob
  queue_as :default

  def perform(donation, campaign_gift_option)
    AdminMailer.notify_failed_gift(donation, campaign_gift_option)
  end
end
