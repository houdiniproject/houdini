class WemoveListener
    def donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end

    def offsite_donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end

    def recurring_donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end
end
