class AddAddressToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :address_id, :integer
    add_index   :tickets, :address_id
  end
end
