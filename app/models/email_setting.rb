# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailSetting < ApplicationRecord

  attr_accessible \
    :user_id, :user,
    :nonprofit_id, :nonprofit,
    :notify_payments,
    :notify_campaigns,
    :notify_events,
    :notify_payouts,
    :notify_recurring_donations

  belongs_to :nonprofit
  belongs_to :user

end
