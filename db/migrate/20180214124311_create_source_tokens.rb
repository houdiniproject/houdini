# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateSourceTokens < ActiveRecord::Migration
  def change
    create_table :source_tokens, id: false do |t|
      t.column :token, "uuid", primary_key: true, null: false
      t.datetime :expiration
      t.references :tokenizable, polymorphic: true
      t.references :event
      t.integer :max_uses, default: 1
      t.integer :total_uses, default: 0
      t.timestamps
    end

    add_index :source_tokens, :token, unique: true
    add_index :source_tokens, :expiration
    add_index :source_tokens, [:tokenizable_id, :tokenizable_type]
  end
end
