class AddCheckNumberIndexToOffsitePayments < ActiveRecord::Migration
  def change
    add_index :offsite_payments, :check_number
  end
end
