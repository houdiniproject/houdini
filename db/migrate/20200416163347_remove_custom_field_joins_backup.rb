class RemoveCustomFieldJoinsBackup < ActiveRecord::Migration
  def up
    drop_table :custom_field_joins_backup
  end

  def down
  end
end
