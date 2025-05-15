# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitCreateJob < GenericJob
    attr_reader :nonprofit_id

    def initialize(nonprofit_id)
      @nonprofit_id = nonprofit_id
    end

    def perform
      Delayed::Job.enqueue JobTypes::NonprofitWelcomeJob.new nonprofit_id
    end
  end
end
