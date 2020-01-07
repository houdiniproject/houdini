class CreditCardPaymentListener
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
    
end
