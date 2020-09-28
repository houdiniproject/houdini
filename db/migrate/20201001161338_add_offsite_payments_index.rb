class AddOffsitePaymentsIndex < ActiveRecord::Migration
  def change
    add_index :offsite_payments, :payment_id
  end
end
