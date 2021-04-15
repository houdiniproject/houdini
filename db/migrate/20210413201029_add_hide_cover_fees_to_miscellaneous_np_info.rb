class AddHideCoverFeesToMiscellaneousNpInfo < ActiveRecord::Migration
  def change
    add_column :miscellaneous_np_infos, :hide_cover_fees, :boolean, {null: false, default: false}
  end
end
