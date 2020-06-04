# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RenameUploaderColumns < ActiveRecord::Migration[5.2]
    def change
        require "houdini_upgrade"
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
            table.fields.each do |field|
                rename_column table.name, field.name, field.migrated_name
            end
        end
    end
end