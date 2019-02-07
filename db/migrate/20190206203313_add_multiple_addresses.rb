class AddMultipleAddresses < ActiveRecord::Migration
  def change
    create_table :crm_addresses do |t|
      t.references :supporter
  
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.string :state_code
      t.string :fingerprint
      t.boolean :deleted
      t.timestamps
    end

    add_index :crm_addresses, :supporter_id
    add_index :crm_addresses, :fingerprint
    add_index :crm_addresses, :deleted
    add_index :crm_addresses, :updated_at

    create_table :address_tags do |t|
      t.string :name
      t.references :crm_address
      t.references :supporter
      t.timestamps
    end

    add_index :address_tags, :crm_address_id
    add_index :address_tags, :supporter_id

    create_table :transaction_addresses do |t|
      t.references :supporter
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.string :state_code
      t.string :fingerprint
      t.references :transactionable, polymorphic:true
      t.timestamps
    end

    add_index :transaction_addresses, :fingerprint
    add_index :transaction_addresses, [:transactionable_id, :transactionable_type], name: "index_transactionable_on_transaction_address"

  end
end
