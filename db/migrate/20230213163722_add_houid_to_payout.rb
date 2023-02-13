class AddHouidToPayout < ActiveRecord::Migration
  def change
    add_column :payouts, :houid, :string
    add_index :payouts, :houid, unique: true
  end
end
