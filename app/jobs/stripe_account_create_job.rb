class StripeAccountCreateJob < ApplicationJob
  queue_as :default

  def perform(nonprofit)
    NonprofitMailer.setup_verification(nonprofit.id).deliver_now
  end
end
