# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# Retrive a stripe account object, catching any errors

module FetchStripeAccount
  def self.with_account_id(stripe_account_id)
    begin
      stripe_acct = Stripe::Account.retrieve(stripe_account_id)
    rescue
      stripe_acct = nil
    end
    stripe_acct
  end
end
