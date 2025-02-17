class VerificationFailedJob < EmailJob
  def perform(nonprofit)
    NonprofitMailer.failed_verification_notice(onprofit).deliver_now
  end
end
