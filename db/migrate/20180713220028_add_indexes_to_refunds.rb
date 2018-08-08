class AddIndexesToRefunds < ActiveRecord::Migration
  def change
    add_index :refunds, :payment_id
  end
end
