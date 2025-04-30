class AddMinimalTrxTablesToCreateDonations < ActiveRecord::Migration
  def change
    create_table :transaction_assignments do |t|
      t.references :transaction, null: false
      t.references :assignable, polymorphic: true, index: {unique: true, name: "idx_trx_assignments_assignable_polymorphic"}, null: false
    end

    create_table :modern_donations do |t|
      t.integer :amount
      t.references :donation, null: false
      t.string :houid, null: false, index: {unique: true}

      t.timestamps
    end

    create_table :subtransactions do |t|
      t.references :transaction, null: false
      t.references :subtransactable, polymorphic: true, null: false, index: {unique: true, name: "idx_subtrx_on_subtransactable_polymorphic"}
      t.datetime "created", comment: "the moment that the subtransaction was created. Could be earlier than created_at if the transaction was in the past."
      t.timestamps
    end

    create_table "offline_transactions" do |t|
      t.integer "amount", null: false
      t.string :houid, null: false, index: {unique: true}
      t.timestamps
    end

    create_table :subtransaction_payments do |t|
      t.references :subtransaction, null: false
      t.references :paymentable, polymorphic: true, null: false, index: {unique: true, name: "idx_subtrxpayments_on_subtransactable_polymorphic"}
      t.datetime "created", comment: "the moment that the subtransaction_payment was created. Could be earlier than created_at if the transaction was in the past."
      t.references :legacy_payment, null: false, index: {unique: true}
      t.timestamps
    end

    create_table :offline_transaction_charges do |t|
      t.string :houid, null: false, index: {unique: true}
      t.timestamps
    end
  end
end
