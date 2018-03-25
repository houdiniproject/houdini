class CreateExports < ActiveRecord::Migration
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
