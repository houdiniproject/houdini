# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class WemoveListener < ApplicationListener
    def donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end

    def offsite_donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end

    def recurring_donation_create(donation)
      WeMoveExecuteForDonationsJob.perform_later(donation)
    end
end
