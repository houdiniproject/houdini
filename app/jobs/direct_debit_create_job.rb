class DirectDebitCreateJob < ApplicationJob
  queue_as :default

  def perform(donation_id, locale)
    DirectDebitCreateNotifyDonorJob.perform_later donation_id, locale
    DirectDebitCreateNotifyNonprofitJob.perform_later donation_id, locale
  end
end
