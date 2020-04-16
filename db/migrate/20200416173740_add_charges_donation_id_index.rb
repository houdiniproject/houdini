class AddChargesDonationIdIndex < ActiveRecord::Migration
  def up
    add_index :charges, :donation_id
  end

  def down
    remove_index :charges, :donation_id
  end
end
