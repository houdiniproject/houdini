# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SetDefaultDeletedToFalseOnCustomFieldDefinition < ActiveRecord::Migration[6.1]
  def change
    change_column_default :custom_field_masters, :deleted, from: nil, to: false
    change_column_null :custom_field_masters, :deleted, false
  end
end
