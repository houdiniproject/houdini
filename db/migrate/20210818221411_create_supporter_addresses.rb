class CreateSupporterAddresses < ActiveRecord::Migration
  def change
    create_table :supporter_addresses do |t|
      t.string :address
      t.string :city
      t.string :zip_code
      t.string :state_code
      t.string :country
      t.boolean :deleted, default: false, null: false
      t.references :supporter, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_column :supporters, :primary_address_id, :integer

    add_foreign_key :supporters, :supporter_addresses, column: :primary_address_id
  end
end
