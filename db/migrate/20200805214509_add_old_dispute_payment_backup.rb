class AddOldDisputePaymentBackup < ActiveRecord::Migration
  def change
    create_table :dispute_payment_backups do |t|
      t.references :dispute
      t.references :payment
    end
  end
end
