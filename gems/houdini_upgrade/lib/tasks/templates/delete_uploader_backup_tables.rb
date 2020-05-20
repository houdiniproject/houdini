# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DeleteUploaderBackupTables < ActiveRecord::Migration[5.2]
    def up
        # delete tables
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each{ |table| drop_table table.backup_table}
    end
end