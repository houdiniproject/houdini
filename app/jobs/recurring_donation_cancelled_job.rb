class RecurringDonationCancelledJob < EmailJob
  def perform(donation)
    DonationMailer.nonprofit_recurring_donation_cancellation(donation.id).deliver_now
  end
end
