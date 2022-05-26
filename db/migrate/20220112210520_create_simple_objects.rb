# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateSimpleObjects < ActiveRecord::Migration
  def change
    create_table :simple_objects do |t|
      t.string :houid
      t.references :parent
      t.references :friend
      t.references :nonprofit
      t.timestamps null: false
    end
  end
end
