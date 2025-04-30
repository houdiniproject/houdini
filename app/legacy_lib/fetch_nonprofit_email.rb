# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchNonprofitEmail
  def self.with_charge charge
    nonprofit = charge.nonprofit
    nonprofit.email.blank? ? Settings.mailer.email : nonprofit.email
  end

  def self.with_donation donation
    nonprofit = donation.nonprofit
    nonprofit.email.blank? ? Settings.mailer.email : nonprofit.email
  end
end
