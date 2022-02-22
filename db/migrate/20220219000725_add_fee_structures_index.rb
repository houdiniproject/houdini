class AddFeeStructuresIndex < ActiveRecord::Migration
  def change
    add_index :fee_structures, :fee_era_id
  end
end
