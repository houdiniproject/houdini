class AddFirstChargeEmailToMiscellaneousNpInfos < ActiveRecord::Migration
  def change
    add_column :miscellaneous_np_infos, :first_charge_email_sent, :boolean
  end
end
