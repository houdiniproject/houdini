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

    change_table :crm_addresses do |t|
      t.index :supporter_id
      t.index :fingerprint
      t.index :deleted
      t.index :updated_at
    end

    create_table :address_tags do |t|
      t.string :name
      t.references :crm_address
      t.references :supporter
      t.timestamps
    end

    change_table :address_tags do |t|
      t.index :crm_address_id
      t.index :supporter_id
    end

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

    change_table :transaction_addresses do |t|
      t.index :fingerprint
      t.index [:transactionable_id, :transactionable_type], name: "index_transactionable_on_transaction_address"
    end
  end
end
