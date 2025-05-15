# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DisputeCreatedJob < GenericJob
    attr_reader :dispute

    def initialize(dispute)
      @dispute = dispute
    end

    def perform
      JobQueue.queue(JobTypes::AdminNoticeDisputeCreatedJob, dispute)
    end
  end
end
