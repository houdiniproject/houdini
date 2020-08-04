class AddNetAmountToDispute < ActiveRecord::Migration
  def change
    add_column :disputes, :net_amount, :integer
  end
end
