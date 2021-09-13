# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class RenameTableCustomFieldMasterToCustomFieldDefinition < ActiveRecord::Migration[6.1]
  def change
    rename_table :custom_field_masters, :custom_field_definitions
  end
end
