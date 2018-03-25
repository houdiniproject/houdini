class CreateMiscellaneousNpInfos < ActiveRecord::Migration
  def change
    create_table :miscellaneous_np_infos do |t|
      t.string :donate_again_url
      t.belongs_to :nonprofit
      t.timestamps
    end
  end
end
