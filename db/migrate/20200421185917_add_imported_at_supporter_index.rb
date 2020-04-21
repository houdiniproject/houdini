class AddImportedAtSupporterIndex < ActiveRecord::Migration
  def up
    add_index :supporters, [:nonprofit_id, :imported_at]
  end

  def down
    remove_index :supporters, [:nonprofit_id, :imported_at]
  end
end
