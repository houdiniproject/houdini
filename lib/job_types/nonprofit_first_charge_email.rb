# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitFirstChargeEmail < EmailJob
    attr_reader :nonprofit_id, :charge_id

    def initialize(nonprofit_id, charge_id)
      @nonprofit_id = nonprofit_id
      @charge_id = charge_id
    end

    def perform
      NonprofitMailer.first_charge_email(nonprofit_id).deliver
    end
  end
end