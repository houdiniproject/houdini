class AddAddressToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :address_id, :integer
    add_index   :donations, :address_id
  end
end
