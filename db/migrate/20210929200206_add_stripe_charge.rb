class AddStripeCharge < ActiveRecord::Migration
  def change
    create_table :stripe_charges do |t|
      t.jsonb :object, null: false
      t.string :stripe_charge_id, unique: true, null: false

      t.index :stripe_charge_id
      t.timestamps null: false
    end
  end
end
