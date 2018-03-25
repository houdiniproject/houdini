class RemoveRecurringDonationEventId < ActiveRecord::Migration
  def change
    change_table :recurring_donations do |t|
      t.remove :event_id
    end
  end

end
