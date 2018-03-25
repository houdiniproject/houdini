class AddIndexesForSupporterDeletedAndImport < ActiveRecord::Migration
  def change
    add_index :supporters, :deleted
    add_index :supporters, :import_id
  end
end
