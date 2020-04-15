class RemoveNonprofitPendingBalance < ActiveRecord::Migration
  def up
    remove_column :nonprofits, :pending_balance
  end

  def down
    add_column :nonprofits, :pending_balance, :integer
  end
end
