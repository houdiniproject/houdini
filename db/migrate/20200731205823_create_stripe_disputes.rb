class CreateStripeDisputes < ActiveRecord::Migration
  def change
    create_table :stripe_disputes do |t|
      t.column :object, :jsonb
      t.column :balance_transactions, :jsonb
      t.string :stripe_dispute_id
      t.string :stripe_charge_id
      t.string :status
      t.string :reason
      t.integer :net_change
      t.integer :amount

      t.timestamps
    end

    add_index :stripe_disputes, :id
    add_index :stripe_disputes, :stripe_dispute_id, unique: true
    add_index :stripe_disputes, :stripe_charge_id
  end
end
