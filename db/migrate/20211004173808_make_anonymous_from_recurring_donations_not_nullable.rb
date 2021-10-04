class MakeAnonymousFromRecurringDonationsNotNullable < ActiveRecord::Migration
  def change
    change_column_null :recurring_donations, :anonymous, false, false
  end
end
