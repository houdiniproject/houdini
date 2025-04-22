# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DonorDirectDebitNotificationJob < EmailJob
    attr_reader :donation_id

    def initialize(donation_id, locale = I18n.locale)
      @donation_id = donation_id
      @locale = locale
    end

    def perform
      DonationMailer.donor_direct_debit_notification(@donation_id, @locale).deliver
    end
  end
end
