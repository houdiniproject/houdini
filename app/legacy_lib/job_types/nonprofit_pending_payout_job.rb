# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitPendingPayoutJob < EmailJob
    attr_reader :payout_id

    def initialize(payout_id)
      @payout_id = payout_id
    end

    def perform
      NonprofitMailer.pending_payout_notification(@payout_id).deliver
    end
  end
end
