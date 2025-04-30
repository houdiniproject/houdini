# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DonorPaymentNotificationJob < EmailJob
    attr_reader :donation_id, :payment_id
    def initialize(donation_id, payment_id, locale = I18n.locale)
      @donation_id = donation_id
      @payment_id = payment_id
      @locale = locale
    end

    def perform
      DonationMailer.donor_payment_notification(@donation_id, @payment_id, @locale).deliver
    end
  end
end
