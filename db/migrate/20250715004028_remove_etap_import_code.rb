class RemoveEtapImportCode < ActiveRecord::Migration[7.1]
  def change
    # standard:disable Rails/ReversibleMigration
    drop_table :e_tap_imports
    drop_table :e_tap_import_contacts
    drop_table :e_tap_import_journal_entries
    drop_table :journal_entries_to_items
    drop_table :payment_dupe_statuses
    drop_table :reassignments
    # standard:enable Rails/ReversibleMigration
  end
end
