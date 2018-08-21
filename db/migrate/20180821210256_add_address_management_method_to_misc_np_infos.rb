class AddAddressManagementMethodToMiscNpInfos < ActiveRecord::Migration
  def change
    add_column :miscellaneous_np_infos, :supporter_default_address_strategy, :text
    add_index :miscellaneous_np_infos, :nonprofit_id
  end
end
