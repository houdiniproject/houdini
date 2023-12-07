class DropFullContactJobsTable < ActiveRecord::Migration
  def change
    drop_table :full_contact_jobs
  end
end
