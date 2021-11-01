class CreatePeriodicReportsUsers < ActiveRecord::Migration
  def change
    create_table :periodic_reports_users do |t|
      t.belongs_to :periodic_report
      t.belongs_to :user
    end
  end
end
