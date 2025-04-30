class CreateETapImports < ActiveRecord::Migration
  def change
    create_table :e_tap_imports do |t|
      t.references :nonprofit
      t.timestamps null: false
    end

    create_table :e_tap_import_journal_entries do |t|
      t.references :e_tap_import, index: true
      t.jsonb :row

      #  t.index "row ->> 'Account Number'", using: "GIN", name: "by_account_number"

      t.timestamps null: false
    end

    create_table :journal_entries_to_items do |t|
      t.references :e_tap_import_journal_entry
      t.references :item, polymorphic: true
    end

    # reversible do |dir|
    #   dir.up do
    #     # insert index
    #     execute <<-SQL
    #       CREATE INDEX by_account_number_journal_entries on e_tap_import_journal_entries
    #         USING GIN ("row" jsonb_path_ops);

    #     SQL
    #   end
    #   dir.down do
    #     execute <<-SQL
    #      DROP INDEX by_account_number_journal_entries;
    #     SQL
    #   end
    # end

    create_table :e_tap_import_contacts do |t|
      t.references :e_tap_import, index: true
      t.jsonb :row
      # t.index "row ->> 'Account Number'", using: "GIN", name: "by_account_number"
      t.references :supporter, index: true
      t.timestamps null: false
    end
  end
end
