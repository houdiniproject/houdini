class RemoveETapForeignKeyFromReassignments < ActiveRecord::Migration
  def change
    remove_foreign_key :reassignments, column: :e_tap_import_id
  end
end
