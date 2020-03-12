# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class DonationPaymentCreateJob < GenericJob
    attr_reader :donation_id, :locale

    def initialize(donation_id, locale=I18n.locale)
      @donation_id = donation_id
      @locale = locale
    end

    def perform
      JobQueue.queue(JobTypes::DonorPaymentNotificationJob, donation_id, locale)
      JobQueue.queue(JobTypes::NonprofitPaymentNotificationJob, donation_id)
      JobQueue.queue(JobTypes::NonprofitFirstDonationPaymentJob, donation_id)
    end
  end
end