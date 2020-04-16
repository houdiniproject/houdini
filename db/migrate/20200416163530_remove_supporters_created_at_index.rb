class RemoveSupportersCreatedAtIndex < ActiveRecord::Migration
  def up
    remove_index :supporters, name: "supporters_created_at"
  end

  def down
    add_index :supporters, :created_at, name: "supporters_created_at"
  end
end
