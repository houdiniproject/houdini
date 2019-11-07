class VerificationFailedJob < ApplicationJob
  queue_as :default

  def perform(nonprofit)
    NonprofitMailer.failed_verification_notice(onprofit).deliver_now
  end
end
