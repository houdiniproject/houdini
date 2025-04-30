# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddCustomFieldJoinsBackupTable < ActiveRecord::Migration
  def change
    create_table :custom_field_joins_backup do |t|
      t.integer "custom_field_master_id"
      t.integer "supporter_id"
      t.text "metadata"
      t.text "value"
      t.timestamps
    end
  end
end
