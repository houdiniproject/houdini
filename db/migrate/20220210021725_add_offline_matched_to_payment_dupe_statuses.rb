class AddOfflineMatchedToPaymentDupeStatuses < ActiveRecord::Migration
  def change
    add_column :payment_dupe_statuses, :matched_with_offline, :integer, array: true, default: []
  end
end
