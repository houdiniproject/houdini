class AddIndexToActivities < ActiveRecord::Migration
  def change
    add_index :activities, :supporter_id
    add_index :activities, :nonprofit_id
  end
end
