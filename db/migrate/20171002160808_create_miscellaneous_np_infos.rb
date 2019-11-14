# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateMiscellaneousNpInfos < ActiveRecord::Migration[4.2]
  def change
    create_table :miscellaneous_np_infos do |t|
      t.string :donate_again_url
      t.belongs_to :nonprofit
      t.timestamps
    end
  end
end
