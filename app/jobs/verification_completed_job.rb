class VerificationCompletedJob < EmailJob
  def perform(nonprofit)
    NonprofitMailer.successful_verification_notice(nonprofit).deliver_now
  end
end
