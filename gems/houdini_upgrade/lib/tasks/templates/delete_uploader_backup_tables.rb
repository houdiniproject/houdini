# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class DeleteUploaderBackupTables < ActiveRecord::Migration[5.2]
  def up
    # delete tables
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each { |table| drop_table table.backup_table }
  end
end
