class WeMoveExecuteForDonationsJob < ApplicationJob
  queue_as :default

  def perform(donation)
    QueueDonations.execute_for_donation(donation.id)
  end
end
