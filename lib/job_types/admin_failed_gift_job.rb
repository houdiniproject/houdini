module JobTypes
  class AdminFailedGiftJob < EmailJob
    attr_reader :donation, :campaign_gift_option

    def initialize(donation, campaign_gift_option)
      @donation = donation
      @campaign_gift_option = campaign_gift_option
    end

    def perform
      AdminMailer.notify_failed_gift(@donation, @campaign_gift_option).deliver
    end
  end
end