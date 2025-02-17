# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CreditCardPaymentListener < ApplicationListener
  def self.donation_create(donation, locale, user = nil)
    if donation.payment_provider.to_sym == :credit_card
      PaymentNotificationEmailDonorJob.perform_later donation, locale
      PaymentNotificationEmailNonprofitJob.perform_later donation, user
    end
  end

  def self.recurring_donation_create(donation, locale, user = nil)
    if donation.payment_provider.to_sym == :credit_card
      PaymentNotificationEmailDonorJob.perform_later donation, locale
      PaymentNotificationEmailNonprofitJob.perform_later donation, user
    end
  end

  def self.refund_create(refund)
    RefundNotificationJob.perform_later refund
  end

  def self.recurring_donation_payment_succeeded(donation, locale, user = nil)
    if donation.payment_provider.to_sym == :credit_card
      PaymentNotificationEmailDonorJob.perform_later donation, locale
      PaymentNotificationEmailNonprofitJob.perform_later donation, user
    end
  end

  def self.recurring_donation_payment_failed(donation, locale)
    FailedRecurringDonationPaymentDonorEmailJob.perform_later(donation)
    if donation.recurring_donation.n_failures >= 3
      FailedRecurringDonationPaymentNonprofitEmailJob.perform_later(donation)
    end
  end
end
