module JobTypes
  class NonprofitFailedVerificationJob < EmailJob
    attr_reader :np

    def initialize(np)
      @np = np
    end

    def perform
      NonprofitMailer.failed_verification_notice(@np).deliver
    end
  end
end