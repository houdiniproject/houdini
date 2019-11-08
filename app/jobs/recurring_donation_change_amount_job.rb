class RecurringDonationChangeAmountJob < ApplicationJob
  queue_as :default

  def perform(recurring_donation, previous_amount)
    RecurringDonationChangeAmountDonorEmailJob.perform_later(recurring_donation, previous_amount)
    RecurringDonationChangeAmountNonprofitEmailJob.perform_later(recurring_donation, previous_amount)
  end
end
