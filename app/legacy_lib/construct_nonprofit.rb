# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module ConstructNonprofit
  def self.construct(user, h)
    h[:published] = true
    h[:statement] = h[:name][0..16]
    h.except!(:website) if h[:website].blank?
    stripe_acct = CreateStripeAccount.for_nonprofit(user, h)
    h[:stripe_account_id] = stripe_acct.id
    h
  end
end
