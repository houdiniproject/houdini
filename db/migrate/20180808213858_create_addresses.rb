class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :name
      t.references :supporter
      t.boolean :deleted
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.string :state_code

      t.timestamps
    end
    add_index :addresses, :name
    add_index :addresses, :deleted
    add_index :addresses, :supporter_id
  end
end
