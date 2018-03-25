class AddChangeAmountMessageToMiscellaneousNpInfos < ActiveRecord::Migration
  def change
    add_column :miscellaneous_np_infos, :change_amount_message, :text
  end
end
