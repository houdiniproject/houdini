class FailedRecurringDonationPaymentJob < ApplicationJob
  queue_as :default

  def perform
    FailedRecurringDonationPaymentDonorEmailJob.perform_later donation
    FailedRecurringDonationPaymentNonprofitEmailJob.perform_later donation
  end
end
