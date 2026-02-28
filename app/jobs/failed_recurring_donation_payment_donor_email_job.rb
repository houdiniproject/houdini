class FailedRecurringDonationPaymentDonorEmailJob < EmailJob
  def perform(donation)
    DonationMailer.donor_failed_recurring_donation(donation.id).deliver_now
  end
end
