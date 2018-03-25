class ChangeDddSupporterToHolder < ActiveRecord::Migration
  def change
    rename_column :direct_debit_details, :supporter_id, :holder_id
  end
end
