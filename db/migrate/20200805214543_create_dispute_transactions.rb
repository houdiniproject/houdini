class CreateDisputeTransactions < ActiveRecord::Migration
  def up
    create_table :dispute_transactions do |t|
      t.references :dispute
      t.references :payment
      t.integer :gross_amount, default: 0
      t.integer :fee_total, default: 0
      t.integer :net_amount, default: 0
      t.boolean :disbursed, default: false
      t.string :stripe_transaction_id
      t.datetime :date
      t.timestamps
    end
    add_index :dispute_transactions, :dispute_id
    add_index :dispute_transactions, :payment_id

    Dispute.all.each do |d|
      d.dispute_transactions.create(gross_amount: d.gross_amount * -1, disbursed: d.status == "lost_and_paid", payment: Payment.find(d.payment_id), date: d.started_at) if d.status == "lost" || d.status == "lost_and_paid"
      if d.status == "lost_and_paid"
        d.status = :lost
        d.save!
      end

      DisputePaymentBackup.create(dispute: d, payment_id: d.payment_id)
    end
    remove_column :disputes, :payment_id
  end

  def down
    add_column :disputes, :payment_id, :integer
    add_index :disputes, :payment_id

    Dispute.all.each do |d|
      if d.dispute_transactions&.first&.disbursed && d.status == "lost"
        d.status = :lost_and_paid
      end
      d.save!
    end
    DisputePaymentBackup.all.each do |dpb|
      d = dpb.dispute
      d.payment_id = dpb.payment_id
      d.save!
    end

    DisputePaymentBackup.delete_all

    drop_table :dispute_transactions
  end
end
