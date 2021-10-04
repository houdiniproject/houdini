class ChangeAnonymousDefaultFromRecurringDonations < ActiveRecord::Migration
  def change
    change_column_default :recurring_donations, :anonymous, false
  end
end
