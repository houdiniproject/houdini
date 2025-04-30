# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitNewBankAccountJob < EmailJob
    attr_reader :ba

    def initialize(ba)
      @ba = ba
    end

    def perform
      NonprofitMailer.new_bank_account_notification(@ba).deliver
    end
  end
end
