# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DonationPaymentCreateJob < GenericJob
    attr_reader :donation_id, :locale, :payment_id

    def initialize(donation_id, payment_id, locale = I18n.locale)
      @donation_id = donation_id
      @payment_id = payment_id
      @locale = locale
    end

    def perform
      JobQueue.queue(JobTypes::DonorPaymentNotificationJob, donation_id, payment_id, locale)
      JobQueue.queue(JobTypes::NonprofitPaymentNotificationJob, donation_id, payment_id)
      JobQueue.queue(JobTypes::NonprofitFirstDonationPaymentJob, donation_id)
    end
  end
end
