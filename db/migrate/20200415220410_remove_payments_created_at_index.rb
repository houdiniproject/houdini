class RemovePaymentsCreatedAtIndex < ActiveRecord::Migration
  def up
    remove_index :payments, :created_at
  end

  def down
    add_index :payments, :created_at
  end
end
