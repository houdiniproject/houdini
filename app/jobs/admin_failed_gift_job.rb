class AdminFailedGiftJob < EmailJob
  def perform(donation, campaign_gift_option)
    AdminMailer.notify_failed_gift(donation, campaign_gift_option).deliver_now
  end
end
