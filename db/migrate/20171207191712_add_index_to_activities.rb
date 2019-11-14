# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexToActivities < ActiveRecord::Migration[4.2]
  def change
    add_index :activities, :supporter_id
    add_index :activities, :nonprofit_id
  end
end
