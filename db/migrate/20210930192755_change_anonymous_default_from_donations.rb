class ChangeAnonymousDefaultFromDonations < ActiveRecord::Migration
  def change
    change_column_default :donations, :anonymous, false
  end
end
