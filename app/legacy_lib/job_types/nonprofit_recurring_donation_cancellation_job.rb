# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitRecurringDonationCancellationJob < EmailJob
    attr_reader :donation_id

    def initialize(donation_id)
      @donation_id = donation_id
    end

    def perform
      DonationMailer.nonprofit_recurring_donation_cancellation(@donation_id).deliver
    end
  end
end
