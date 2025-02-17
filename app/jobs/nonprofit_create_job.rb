class NonprofitCreateJob < EmailJob
  def perform(nonprofit)
    NonprofitMailer.welcome(nonprofit.id).deliver_now
  end
end
