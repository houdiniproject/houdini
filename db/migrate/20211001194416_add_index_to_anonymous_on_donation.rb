class AddIndexToAnonymousOnDonation < ActiveRecord::Migration
  def change
    add_index :donations, :anonymous
  end
end
