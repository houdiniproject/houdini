module JobTypes
  class DonorFailedRecurringDonationJob < EmailJob
    attr_reader :donation_id

    def initialize(donation_id)
      @donation_id = donation_id
    end

    def perform
      DonationMailer.donor_failed_recurring_donation(@donation_id).deliver
    end
  end
end