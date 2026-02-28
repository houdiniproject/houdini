# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class BackupUploaderColumns < ActiveRecord::Migration[5.2]
  def up
    # copy all
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |uploader_table|
      create_table uploader_table.backup_table do |table|
        table.references uploader_table.name, foreign_key: true, index: {name: "idx_#{uploader_table.backup_table}_on_fk"}
        uploader_table.fields.each do |f|
          table.string f.migrated_name
        end
      end
    end

    # copy all
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      execute <<-SQL
            INSERT INTO #{table.backup_table} (#{table.foreign_key}, #{table.fields.map(&:migrated_name).join(", ")})
            ( SELECT id, #{table.fields.map(&:migrated_name).join(", ")} FROM #{table.name})
      SQL
    end

    # delete columns
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      table.fields.each do |f|
        remove_column table.name, f.migrated_name
      end
    end
  end

  def down
    ## readd columns
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      table.fields.each do |f|
        add_column table.name, f.migrated_name, :string
      end
    end

    # copy all
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each do |table|
      execute <<-SQL
            UPDATE  #{table.name}  SET (#{table.fields.map(&:migrated_name).join(", ")}) = (
                SELECT #{table.fields.map { |f| table.backup_table + "." + f.migrated_name }.join(", ")} FROM #{table.backup_table}
                WHERE #{table.backup_table}.#{table.foreign_key} = #{table.name}.id
            )
      SQL
    end
    # delete tables
    HoudiniUpgrade::UPLOADERS_TO_MIGRATE.each { |entity, _| drop_table entity.backup_table }
  end
end
