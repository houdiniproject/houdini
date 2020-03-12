# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitFirstDonationPaymentJob < GenericJob
    attr_reader :donation_id

    def initialize(donation_id)
      @donation_id = donation_id
    end

    def perform
      d = Donation.find(donation_id)
      nonprofit = d.nonprofit
      charge = d.charges.first
      if (charge && nonprofit.charges.order('id ASC').first == charge)
        JobQueue.queue(NonprofitFirstChargeEmail, nonprofit.id, charge.id)
      end
    end
  end
end