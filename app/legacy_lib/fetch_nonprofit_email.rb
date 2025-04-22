# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module FetchNonprofitEmail
  def self.with_charge(charge)
    nonprofit = charge.nonprofit
    nonprofit.email.presence || Houdini.hoster.support_email
  end

  def self.with_donation(donation)
    nonprofit = donation.nonprofit
    nonprofit.email.presence || Houdini.hoster.support_email
  end
end
