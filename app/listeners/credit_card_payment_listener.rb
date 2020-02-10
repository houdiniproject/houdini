class CreditCardPaymentListener < ApplicationListener
    def donation_create(donation, locale, user=nil)
      if donation.payment_provider == :credit_card
        PaymentNotificationEmailDonorJob.perform_later donation, locale
        PaymentNotificationEmailNonprofitJob.perform_later donation, user
      end
    end

    def recurring_donation_create(donation, locale, user=nil)
      if donation.payment_provider == :credit_card
        PaymentNotificationEmailDonorJob.perform_later donation, locale
        PaymentNotificationEmailNonprofitJob.perform_later donation, user
      end
    end

    def refund_create(refund)
      RefundNotificationJob.perform_later refund
    end

    def recurring_donation_payment_succeeded(donation, locale, user=nil)
      if donation.payment_provider == :credit_card
        PaymentNotificationEmailDonorJob.perform_later donation, locale
        PaymentNotificationEmailNonprofitJob.perform_later donation, user
      end
    end

    def recurring_donation_payment_failed(donation, locale)
      FailedRecurringDonationPaymentDonorEmailJob.perform_later(donation)
      if (donation.recurring_donation.n_failures >= 3)
        FailedRecurringDonationPaymentNonprofitEmailJob.perform_later(donation)
      end
    end
end
