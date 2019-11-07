class RecurringDonationCancelledJob < ApplicationJob
  queue_as :default

  def perform(donation)
    DonationMailer.nonprofit_recurring_donation_cancellation(donation.id).deliver_later
  end
end
