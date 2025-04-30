# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class AdminNoticeDisputeUpdatedJob < EmailJob
    attr_reader :dispute

    def initialize(dispute)
      @dispute = dispute
    end

    def perform
      DisputeMailer.updated(dispute).deliver
    end
  end
end
