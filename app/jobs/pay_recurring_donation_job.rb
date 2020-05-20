class PayRecurringDonationJob < ApplicationJob
  queue_as :rec_don_payments

  def perform(id)
    PayRecurringDonation.with_stripe(id)
  end
end
