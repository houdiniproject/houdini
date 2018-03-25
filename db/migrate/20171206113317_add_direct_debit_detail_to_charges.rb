class AddDirectDebitDetailToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :direct_debit_detail_id, :integer
  end
end
