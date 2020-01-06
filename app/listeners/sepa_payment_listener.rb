class SepaPaymentListener
    def donation_create(donation)
      if donation.payment_provider == :sepa
        DirectDebitCreateNotifyNonprofitJob.perform_later(donation.id)
        DirectDebitCreateNotifyDonorJob.perform_later donation.id, locale
      end
    end

    def recurring_donation_create(donation, locale, user=nil)
      
    end
end
