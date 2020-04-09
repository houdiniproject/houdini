class AddIndexForNonprofitDeletedOnTagMasters < ActiveRecord::Migration
  def up
    remove_index :tag_masters, :deleted
    execute <<-SQL
      CREATE INDEX tag_masters_nonprofit_id_not_deleted ON tag_masters (nonprofit_id, deleted) WHERE (NOT deleted)
    SQL
  end

  def down
    add_index :tag_masters, :deleted
    execute <<-SQL
      DROP INDEX tag_masters_nonprofit_deleted ON tag_masters;
    SQL
  end
end
