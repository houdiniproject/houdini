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
      t.string :fingerprint
      t.boolean :deleted
      t.timestamps
    end
    add_index :addresses, :name
    add_index :addresses, :supporter_id
    add_index :addresses, :type
    add_index :addresses, :fingerprint
    add_index :addresses, :deleted
    add_index :addresses, :updated_at


    create_table :address_tags do |t|
      t.string :name
      t.references :address
      t.references :supporter
      t.timestamps
    end

    create_table :address_to_transaction_relations do |t|
      t.references :address, index:true
      t.references :transactionable, polymorphic:true, index:true
      t.timestamps
    end
  end
end
