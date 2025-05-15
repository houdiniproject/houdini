# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DisputeUpdatedJob < GenericJob
    attr_reader :dispute

    def initialize(dispute)
      @dispute = dispute
    end

    def perform
      JobQueue.queue(JobTypes::AdminNoticeDisputeUpdatedJob, dispute)
    end
  end
end
