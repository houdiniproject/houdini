# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexToActivities < ActiveRecord::Migration
  def change
    add_index :activities, :supporter_id
    add_index :activities, :nonprofit_id
  end
end
