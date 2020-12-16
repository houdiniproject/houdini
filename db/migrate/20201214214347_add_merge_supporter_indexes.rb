class AddMergeSupporterIndexes < ActiveRecord::Migration
  def change
    add_index :offsite_payments, :supporter_id
    add_index :recurring_donations, :supporter_id
  end
end
