# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class NormalizeStartAndEndDatetimesForEventsAndCampaigns < ActiveRecord::Migration
  def up
    add_column :events, :start_datetime, :datetime
    add_column :events, :end_datetime, :datetime
    add_column :campaigns, :end_datetime, :datetime
    Qx.update(:events)
      .set(%(start_datetime = ("date" + start_time), end_datetime = ("date" + end_time)))
      .where("created_at > '2012-01-01'")
      .execute
    Qx.update(:campaigns)
      .set("end_datetime = (expiration + end_time)")
      .where("created_at > '2012-01-01'")
      .execute
    remove_column :events, :end_time
    remove_column :events, :start_time
    remove_column :events, :date
    remove_column :campaigns, :expiration
    remove_column :campaigns, :end_time
  end

  def down
    add_column :events, :end_time, :time
    add_column :events, :start_time, :time
    add_column :events, :date, :date
    add_column :campaigns, :expiration, :date
    add_column :campaigns, :end_time, :time
    Qx.update(:events)
      .set(%(end_time = end_datetime::time, start_time = start_datetime::time, "date" = start_datetime::date))
      .where("created_at > '2012-01-01'")
      .execute
    Qx.update(:campaigns)
      .set("end_time = end_datetime::time, expiration = end_datetime::date")
      .where("created_at > '2012-01-01'")
      .execute
    remove_column :events, :start_datetime
    remove_column :events, :end_datetime
    remove_column :campaigns, :end_datetime
  end
end
