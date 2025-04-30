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
      if nonprofit && d.charges.any?
        np_infos = nonprofit.miscellaneous_np_info || nonprofit.create_miscellaneous_np_info
        np_infos.with_lock("FOR UPDATE") do
          if !np_infos.first_charge_email_sent
            JobQueue.queue(JobTypes::NonprofitFirstChargeEmailJob, nonprofit.id)
            np_infos.first_charge_email_sent = true
            np_infos.save!
          end
        end
      end
    end
  end
end
