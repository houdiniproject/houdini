module OneOff
  class RunPayouts
    attr_reader :beginning_of_month, :support_email, :support_ip, :logger

    def initialize
      @beginning_of_month = Time.zone.now.beginning_of_month
      @support_email = "support@commitchange.com"
      @support_ip = "127.0.0.1"
      @logger = Rails.logger
    end

    def execute
      # get all activated nonprofits that can make payouts
      nps = Nonprofit.includes(:bank_account, :stripe_account).activated.select { |np| np.can_make_payouts? }

      nps_for_payout = nps_with_payout_ids(nps)

      results = nps_for_payout.map do |np|
        begin
          payload = build_payout_payload(np)

          logger.info "Insert Payout for: #{np.id}: payload: #{payload}"
          result = InsertPayout.with_stripe(np.id, payload, {date: beginning_of_month})
        rescue e
          result = e
        end
        [np, result]
      end

      not_pending = results.select { |np, result| result["status"] != "pending" }
      write_report(not_pending)
      nil
    end

    def write_report(not_pending_nps)
      report = CSV.generate do |csv|
        csv << ["id", "name", "error"]
        not_pending_nps.each do |np, result|
          csv << [np.id, np.name, result["status"].to_s]
        end
      end

      logger.info report
    end

    def build_payout_payload(np)
      {stripe_account_id: np.stripe_account_id,
       email: support_email,
       user_ip: support_ip,
       bank_name: np.bank_account.name}
    end

    # keep only nonprofits that have available payments and filter only nonprofits that have a connected bank account
    def nps_with_payout_ids(nps)
      nps.select { |np| ids_for_payout(np).any? }
    end

    # Use a method in the QueryPayments lib module that will find all available payment rows that can be paid out
    def ids_for_payout(np)
      QueryPayments.ids_for_payout(np.id, date: beginning_of_month)
    end
  end
end
