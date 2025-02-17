# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class ChangeTagMastersToTagDefinitions < ActiveRecord::Migration[6.1]
  def change
    rename_table :tag_masters, :tag_definitions

    remove_index :tag_joins, name: :tag_join_supporter_unique_idx
    remove_index :tag_joins, name: :tag_joins_tag_master_id

    rename_column :email_lists, :tag_master_id, :tag_definition_id
    rename_column :tag_joins, :tag_master_id, :tag_definition_id
    rename_column :tag_joins_backup, :tag_master_id, :tag_definition_id

    add_index :tag_joins, :tag_definition_id
    add_index :tag_joins, %i[tag_definition_id supporter_id], unique: true
  end
end
