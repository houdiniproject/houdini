class AddDonationsIndex < ActiveRecord::Migration
  def change
    add_index :donations, :nonprofit_id
  end
end
