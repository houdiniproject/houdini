class FailedRecurringDonationPaymentNonprofitEmailJob < EmailJob
  def perform(donation)
    DonationMailer.nonprofit_failed_recurring_donation(donation.id).deliver_now
  end
end
