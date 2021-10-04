class MakeAnonymousFromDonationsNotNullable < ActiveRecord::Migration
  def change
    change_column_null :donations, :anonymous, false, false
  end
end
