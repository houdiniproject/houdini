# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexForTagJoinsAndAddConstraint < ActiveRecord::Migration
  def up
    ids = DeleteTagJoins.find_multiple_tag_joins
    DeleteTagJoins.copy_and_delete(ids)
    add_index :tag_joins, [:tag_master_id, :supporter_id], unique: true, name: "tag_join_supporter_unique_idx"
  end

  def down
    remove_index(:tag_joins, name: "tag_join_supporter_unique_idx")
    DeleteTagJoins.revert
  end
end
