# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require_relative "column_to_migrate"
module HoudiniUpgrade
  class TableToMigrate
    attr_reader :fields, :name
    def initialize(original_table_name, original_field_names)
      @name = original_table_name.to_s
      @fields = original_field_names.map { |i| ColumnToMigrate.new(i) }
    end

    def class_name
      @name.classify
    end

    def backup_table
      @name + "_uploader_backups"
    end

    def foreign_key
      @name + "_id"
    end
  end
end
