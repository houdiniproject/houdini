# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class EmailSetting < ApplicationRecord
  # :user_id, :user,
  # :nonprofit_id, :nonprofit,
  # :notify_payments,
  # :notify_campaigns,
  # :notify_events,
  # :notify_payouts,
  # :notify_recurring_donations

  belongs_to :nonprofit
  belongs_to :user
end
