class StripeAccountCreateJob < EmailJob
  def perform(nonprofit)
    NonprofitMailer.setup_verification(nonprofit.id).deliver_now
  end
end
