# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateExports < ActiveRecord::Migration[4.2]
  def change
    create_table :exports do |t|
      t.integer :user_id
      t.integer :nonprofit_id
      t.string :status
      t.string :exception
      t.datetime :ended
      t.string :export_type
      t.string :parameters
      t.string :url

      t.timestamps
    end

    add_index :exports, :user_id
    add_index :exports, :nonprofit_id
  end
end
