# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "stripe"

module StripeUtils
  def self.create_transfer(net_amount, stripe_account_id, currency)
    Stripe::Payout.create({
      amount: net_amount,
      currency: currency || Settings.intntl.currencies[0]
    }, {
      stripe_account: stripe_account_id
    })
  end
end
