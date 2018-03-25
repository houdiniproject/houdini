class AddChargesPaymentIdIndex < ActiveRecord::Migration
  def change
    add_index :charges, :payment_id
  end
end
