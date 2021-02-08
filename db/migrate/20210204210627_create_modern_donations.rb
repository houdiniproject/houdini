class CreateModernDonations < ActiveRecord::Migration[6.1]
  def change
    create_table :modern_donations, id: :string do |t|
      t.integer :amount
      t.references :donation

      t.timestamps
    end
  end
end
