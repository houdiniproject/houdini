class CreateStripeChargePayments < ActiveRecord::Migration
  def change
    create_table :stripe_transactions do |t|
      t.integer :amount, null: false
      t.string :houid, {index: true, null: false}

      t.timestamps
    end

    create_table :stripe_transaction_charges do |t|
      t.string :houid, {index: true, null: false}
      t.timestamps
    end

    create_table :stripe_transaction_disputes do |t|
      t.string :houid, {index: true, null: false}
      t.timestamps
    end

    create_table :stripe_transaction_refunds do |t|
      t.string :houid, {index: true, null: false}
      t.timestamps
    end

    create_table :stripe_transaction_dispute_reversals do |t|
      t.string :houid, {index: true, null: false}
      t.timestamps
    end
  end
end
