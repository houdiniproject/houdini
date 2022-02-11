class CreateReassignments < ActiveRecord::Migration
  def change
    create_table :reassignments do |t|
      t.references :item, polymorphic: true
      t.references :e_tap_import, index: true, foreign_key: true
      t.timestamps null: false
      t.integer :source_supporter_id
      t.integer :target_supporter_id
    end
  end
end
