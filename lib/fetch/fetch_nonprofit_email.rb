# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module FetchNonprofitEmail
  def self.with_charge(charge)
    nonprofit = charge.nonprofit
    nonprofit.email.blank? ? Houdini.hoster.support_email : nonprofit.email
  end

  def self.with_donation(donation)
    nonprofit = donation.nonprofit
    nonprofit.email.blank? ? Houdini.hoster.support_email : nonprofit.email
  end
end
