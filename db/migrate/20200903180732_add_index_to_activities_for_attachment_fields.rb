class AddIndexToActivitiesForAttachmentFields < ActiveRecord::Migration
  def change
    add_index :activities, [:attachment_type, :attachment_id]
  end
end
