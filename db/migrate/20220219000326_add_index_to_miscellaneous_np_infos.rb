class AddIndexToMiscellaneousNpInfos < ActiveRecord::Migration
  def change
    add_index :miscellaneous_np_infos, :nonprofit_id
  end
end
