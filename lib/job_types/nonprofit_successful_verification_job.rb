# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitSuccessfulVerificationJob < EmailJob
    attr_reader :np

    def initialize(np)
      @np = np
    end

    def perform
      NonprofitMailer.successful_verification_notice(@np).deliver
    end
  end
end