class AddIndexesToEvents < ActiveRecord::Migration
  def up
    add_index :events, :nonprofit_id
    add_index :events, [:nonprofit_id, :deleted, :published]
    add_index :events, [:nonprofit_id, :deleted, :published, :end_datetime], name: "events_nonprofit_id_not_deleted_and_published_endtime"
  end

  def down
    remove_index :events, :nonprofit_id
    remove_index :events, [:nonprofit_id, :deleted, :published]
    remove_index :events, name: "events_nonprofit_id_not_deleted_and_published_endtime"
  end
end
