# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class WemoveListener < ApplicationListener
  def self.donation_create(donation)
    WeMoveExecuteForDonationsJob.perform_later(donation)
  end

  def self.offsite_donation_create(donation)
    WeMoveExecuteForDonationsJob.perform_later(donation)
  end

  def self.recurring_donation_create(donation)
    WeMoveExecuteForDonationsJob.perform_later(donation)
  end
end
