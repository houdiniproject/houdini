# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BackupUploaderColumns < ActiveRecord::Migration[5.2]
    def up
        # copy all 
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
            create_table table.backup_table do |table|
                table.references table.name, index:true
                table.fields.each do |f|
                    table.string f.migrated_name
                end
            end
        end
        # copy all 
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
            
            execute <<-SQL
            INSERT INTO #{table.backup_table} (#{table.foreign_key}, #{table.fields.map(&:migrated_name).join(', ')})
            VALUES ( SELECT id, #{table.fields.map(&:migrated_name).join(', ')} FROM #{table.name})
            SQL;
        end

        # delete columns
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
           
            fields.each do |f|
                drop_column table.name, f.migrated_name
            end
        end
    end

    def down
        ## readd columns
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
            fields.each do |f|
                add_column table.name, f.migrated_name, :string
            end
        end

        # copy all 
        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
            execute <<-SQL
            UPDATE  #{table.name}  SET (#{table.fields.map(&:migrated_name).join(', ')}) = (
                SELECT (#{table.fields.map(&:migrated_name).join(', ')}) FROM #{table.backup_table}
                WHERE #{table.backup_table}.#{table.foreign_key} = #{table.name}.id
            )

            SQL;
        end
        # delete tables

        HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each{ |entity, _| drop_table table.backup_table}
        
    
    end
end