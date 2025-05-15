# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitWelcomeJob < EmailJob
    attr_reader :nonprofit_id

    def initialize(nonprofit_id)
      @nonprofit_id = nonprofit_id
    end

    def perform
      NonprofitMailer.welcome(@nonprofit_id).deliver
    end
  end
end
