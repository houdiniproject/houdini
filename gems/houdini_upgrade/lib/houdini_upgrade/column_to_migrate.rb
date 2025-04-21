# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module HoudiniUpgrade
  class ColumnToMigrate
    attr_reader :name
    def initialize(original_column_name)
      @name = original_column_name.to_s
    end

    def migrated_name
      @name + "_temp"
    end
  end
end
