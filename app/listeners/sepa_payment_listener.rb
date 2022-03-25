# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SepaPaymentListener < ApplicationListener
    def self.donation_create(donation, locale, user=nil)
      if donation.payment_provider == :sepa
        DirectDebitCreateNotifyNonprofitJob.perform_later(donation.id)
        DirectDebitCreateNotifyDonorJob.perform_later donation.id, locale
      end
    end
end
