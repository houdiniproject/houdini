class AddIndexesToRecurringDonations < ActiveRecord::Migration
  def change
    add_index :recurring_donations, :donation_id
  end
end
