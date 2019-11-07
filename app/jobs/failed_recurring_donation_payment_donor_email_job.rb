class FailedRecurringDonationPaymentDonorEmailJob < ApplicationJob
  queue_as :default

  def perform(donation)
    DonationMailer.donor_failed_recurring_donation(donation.id).deliver_now
  end
end
