# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchNonprofitEmail
  def self.with_charge charge
    nonprofit = charge.nonprofit
    nonprofit.email.presence || Settings.mailer.email
  end

  def self.with_donation donation
    nonprofit = donation.nonprofit
    nonprofit.email.presence || Settings.mailer.email
  end
end
