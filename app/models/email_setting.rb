class EmailSetting < ActiveRecord::Base

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
