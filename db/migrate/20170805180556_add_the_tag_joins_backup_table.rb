class AddTheTagJoinsBackupTable < ActiveRecord::Migration
  def up
    create_table :tag_joins_backup do |t|
      t.integer 'tag_master_id'
      t.integer 'supporter_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.text 'metadata'
    end
  end

  def down
    drop_table :tag_joins_backup
  end
end
