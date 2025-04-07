# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module ConstructNonprofit
  def self.construct(user, h)
    h[:verification_status] = "unverified"
    h[:published] = true
    h[:statement] = h[:name][0..16]
    h.except!(:website) if h[:website].blank?
    stripe_acct = CreateStripeAccount.for_nonprofit(user, h)
    h[:stripe_account_id] = stripe_acct.id
    h
  end
end
