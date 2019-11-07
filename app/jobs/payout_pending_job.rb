class PayoutPendingJob < ApplicationJob
  queue_as :default

  def perform(payout)
    NonprofitMailer.pending_payout_notification(payout.id).deliver_now
  end
end
