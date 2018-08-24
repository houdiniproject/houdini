class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :name
      t.references :supporter
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.string :state_code
      t.string :type
      t.string :calculated_hash
      t.boolean :deleted
      t.timestamps
    end
    add_index :addresses, :name
    add_index :addresses, :supporter_id
    add_index :addresses, :type
    add_index :addresses, :calculated_hash
    add_index :addresses, :deleted
    add_index :addresses, :updated_at


    add_column :donations, :transaction_address_id, :integer
    add_index :donations, :transaction_address_id
    add_column :tickets, :transaction_address_id, :integer
    add_index :tickets, :transaction_address_id


    create_table :address_tags do |t|
      t.string :name
      t.references :address
      t.references :supporter
      t.timestamps
    end
  end
end
