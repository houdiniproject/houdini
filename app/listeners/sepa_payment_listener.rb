class SepaPaymentListener < ApplicationListener
    def donation_create(donation)
      if donation.payment_provider == :sepa
        DirectDebitCreateNotifyNonprofitJob.perform_later(donation.id)
        DirectDebitCreateNotifyDonorJob.perform_later donation.id, locale
      end
    end
end
