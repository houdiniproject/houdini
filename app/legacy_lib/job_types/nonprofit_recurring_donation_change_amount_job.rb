# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitRecurringDonationChangeAmountJob < EmailJob
    attr_reader :donation_id, :previous_amount

    def initialize(donation_id, previous_amount = nil)
      @donation_id = donation_id
      @previous_amount = previous_amount
    end

    def perform
      DonationMailer.nonprofit_recurring_donation_change_amount(@donation_id, @previous_amount).deliver
    end
  end
end
