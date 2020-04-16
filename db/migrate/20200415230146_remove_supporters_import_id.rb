class RemoveSupportersImportId < ActiveRecord::Migration
  def up
    remove_index :supporters, :import_id
  end

  def down
    add_index :supporters, :import_id
  end
end
