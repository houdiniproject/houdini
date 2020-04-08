class AddTagMasterDeletedIndex < ActiveRecord::Migration
  def change
    add_index :tag_masters, :deleted
  end
end
