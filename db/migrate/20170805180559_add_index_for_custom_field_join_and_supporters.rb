# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexForCustomFieldJoinAndSupporters < ActiveRecord::Migration[4.2]
  def up
    ids = DeleteCustomFieldJoins.find_multiple_custom_field_joins
    DeleteCustomFieldJoins.copy_and_delete(ids)
    add_index :custom_field_joins, %i[custom_field_master_id supporter_id], unique: true, name: 'custom_field_join_supporter_unique_idx'
  end

  def down
    remove_index(:custom_field_joins, name: 'custom_field_join_supporter_unique_idx')
    DeleteCustomFieldJoins.revert
  end
end
