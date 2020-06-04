class PayRecurringDonationsJob < ApplicationJob
  queue_as :default

  def perform(*ids)
    ids.each do |id|
      PayRecurringDonationJob.perform_later(id)
    end
  end
end
