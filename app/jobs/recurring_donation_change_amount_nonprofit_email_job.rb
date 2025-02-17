class RecurringDonationChangeAmountNonprofitEmailJob < EmailJob
  def perform(recurring_donation, previous_amount)
    DonationMailer.nonprofit_recurring_donation_change_amount(recurring_donation.id, previous_amount).deliver_now
  end
end
