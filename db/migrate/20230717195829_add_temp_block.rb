class AddTempBlock < ActiveRecord::Migration
  def change
    add_column :miscellaneous_np_infos, :temp_block, :boolean, default: false
  end
end
