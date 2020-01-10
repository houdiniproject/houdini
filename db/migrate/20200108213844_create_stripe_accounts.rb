class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.string :stripe_account_id, null: false
      t.column :object, :jsonb, null: false
      t.boolean :charges_enabled
      t.boolean :payouts_enabled
      t.boolean :payouts_enabled
      t.string :disabled_reason
      t.column :eventually_due, :jsonb
      t.column :currently_due, :jsonb
      t.column :past_due, :jsonb
      t.column :pending_verification, :jsonb
      t.timestamps
    end

    add_index :stripe_accounts, :id
    add_index :stripe_accounts, :stripe_account_id
  end
end
