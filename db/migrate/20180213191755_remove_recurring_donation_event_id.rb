# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemoveRecurringDonationEventId < ActiveRecord::Migration
  def change
    change_table :recurring_donations do |t|
      t.remove :event_id
    end
  end
end
