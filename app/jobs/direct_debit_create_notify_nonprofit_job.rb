class DirectDebitCreateNotifyNonprofitJob < EmailJob
  def perform(donation_id)
    DonationMailer.nonprofit_payment_notification(donation_id).deliver_now
  end
end
