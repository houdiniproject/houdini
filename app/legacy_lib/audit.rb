# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Audit
  # Given a list of pairs of nonprofit ids and stripe_account_ids (eg [[4341, 'acct_arst'], [3624, 'acct_arst']])
  # Find all their available balances on both stripe and CC
  # Give all the ones that dont match up with the difference
  # Negative difference = more balance on CC
  # Positive difference = more balance on Stripe
  # Returns an array of pairs of ids with balance difference (eg [[4341, -10], [3624, 100]])
  def self.match_available_balances(nps, date)
    date ||= Time.current
    nps.map do |id, stripe_account_id|
      cc_bal = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(id, date: date))["net_amount"]
      stripe_bal = Stripe::Balance.retrieve(stripe_account: stripe_account_id).available.first.amount
      [id, stripe_bal - cc_bal]
    end
  end

  # Print a report of whether saved payout balances match up to the sum of the payment records
  def self.payout_check(id)
    p = Payout.find(id)
    gross = p.payments.sum(:gross_amount)
    fees = p.payments.sum(:fee_total)
    net = p.payments.sum(:net_amount)
    puts [
      [p.gross_amount, p.fee_total, p.net_amount].join(", ") + " -- payout columns",
      [gross, fees, net].join(", ") + " -- summed from payments",
      [p.gross_amount - gross, p.fee_total - fees, p.net_amount - net].join(", ") + " -- differences"
    ].join("\n")
  end

  # Return a list of all Stripe transaction objects for an account
  def self.find_all_transactions(np_id)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    acct = Nonprofit.find(np_id).stripe_account_id
    starting_after = nil
    transfers = []
    loop do
      new_transfers = Stripe::Transfer.all({limit: 100, starting_after: starting_after, destination: acct}).data
      break if new_transfers.empty?
      transfers += new_transfers
      starting_after = new_transfers.last.id
    end
    ActiveRecord::Base.logger = logger
    transfers
  end

  # Given a list of Stripe transaction objects, see if any are missing on CommitChange
  def self.find_missing_charges(transfers)
    transfers
      .map { |t| [t.source_transaction, t.amount] }
      .select { |id, amount| Charge.where(stripe_charge_id: id, amount: amount).empty? }
  end

  # Audit some basic balances for a nonprofit with those on Stripe
  def self.audit_balances(id)
    np = Nonprofit.find(id)
    puts "Stripe Dashboard: https://dashboard.stripe.com/#{np.stripe_account_id}"
    puts "CC Payments: https://commitchange.com/nonprofits/#{id}/payments"
    puts "CC Payouts: https://commitchange.com/nonprofits/#{id}/payouts"

    begin
      stripe_balances = Stripe::Balance.retrieve(stripe_account: np.stripe_account_id)
      available = stripe_balances["available"].first["amount"]
      pending = stripe_balances["pending"].first["amount"]
    rescue Exception
      available = 0
      pending = 0
      puts "UNRECOGNIZED STRIPE ACCOUNT ID: #{np.stripe_account_id}"
    end
    bal = np_balances(id)
    {
      stripe_net: available + pending,
      cc_net: bal["net_amount"],
      diff: bal["net_amount"] - (available + pending)
    }
  end

  # Get the total gross, net
  # Pretty much duped from QueryPayments
  def self.np_balances(np_id)
    payment_ids_expr = Qx.select("DISTINCT payments.id")
      .from(:payments)
      .left_join(
        [:charges, "charges.payment_id=payments.id"],
        [:refunds, "refunds.payment_id=payments.id"],
        [:disputes, "disputes.payment_id=payments.id"]
      )
      .where("payments.nonprofit_id=$id", id: np_id)
      .and_where("refunds.payment_id IS NOT NULL OR charges.payment_id IS NOT NULL OR disputes.payment_id IS NOT NULL")
      .and_where(%(
        (refunds.payment_id IS NOT NULL AND (refunds.disbursed IS NULL OR refunds.disbursed='f'))
        OR (charges.status='available' OR charges.status='pending')
        OR (disputes.status='lost')
       ))
    Qx.select(
      "coalesce(SUM(payments.gross_amount), 0) AS gross_amount",
      "coalesce(SUM(payments.fee_total), 0) AS fee_total",
      "coalesce(SUM(payments.net_amount), 0) AS net_amount",
      "COUNT(payments.*) AS count"
    )
      .from(:payments)
      .where("payments.id IN ($ids)", ids: payment_ids_expr)
      .execute
      .first
  end
end
