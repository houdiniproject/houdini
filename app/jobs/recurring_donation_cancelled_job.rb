# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RecurringDonationCancelledJob < ActiveJob::Base
  queue_as :default

  def perform(recurring_donation)
    recurring_donation.supporter&.active_email_lists&.update_member_on_all_lists
  end
end
