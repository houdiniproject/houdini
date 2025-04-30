# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexForCustomFieldJoinAndSupporters < ActiveRecord::Migration
  def up
    ids = DeleteCustomFieldJoins.find_multiple_custom_field_joins
    DeleteCustomFieldJoins.copy_and_delete(ids)
    add_index :custom_field_joins, [:custom_field_master_id, :supporter_id], unique: true, name: "custom_field_join_supporter_unique_idx"
  end

  def down
    remove_index(:custom_field_joins, name: "custom_field_join_supporter_unique_idx")
    DeleteCustomFieldJoins.revert
  end
end
