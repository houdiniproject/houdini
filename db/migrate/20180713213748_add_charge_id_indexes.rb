class AddChargeIdIndexes < ActiveRecord::Migration
  def change
    add_index :refunds, :charge_id
  end
end
