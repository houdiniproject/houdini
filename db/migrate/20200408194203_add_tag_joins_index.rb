class AddTagJoinsIndex < ActiveRecord::Migration
  def change
    add_index :tag_joins, :tag_master_id
  end
end
