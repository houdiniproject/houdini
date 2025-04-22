# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class AdminFailedGiftJob < EmailJob
    attr_reader :donation, :campaign_gift_option, :payment

    def initialize(donation, payment, campaign_gift_option)
      @donation = donation
      @payment = payment
      @campaign_gift_option = campaign_gift_option
    end

    def perform
      AdminMailer.notify_failed_gift(@donation, @payment, @campaign_gift_option).deliver
    end
  end
end
