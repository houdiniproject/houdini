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
      t.references :transaction_entity, polymorphic: true

      t.timestamps
    end
    add_index :addresses, :name
    add_index :addresses, :supporter_id
    add_index :addresses, :type
    add_index :addresses, :calculated_hash
    add_index :addresses, :deleted
    add_index :addresses, [:transaction_entity_id, :transaction_entity_type], name: "index_address_on_transaction_entity"


    create_table :address_tags do |t|
      t.string :name
      t.references :address
      t.references :supporter
      t.timestamps
    end
  end
end
