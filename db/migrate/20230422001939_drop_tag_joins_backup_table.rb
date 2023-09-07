class DropTagJoinsBackupTable < ActiveRecord::Migration
  def change
    drop_table :tag_joins_backup
  end
end
