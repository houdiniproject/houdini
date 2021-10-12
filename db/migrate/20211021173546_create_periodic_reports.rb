class CreatePeriodicReports < ActiveRecord::Migration
  def change
    create_table :periodic_reports do |t|
      t.boolean :active, default: false, null: false
      t.string :report_type, null: false
      t.string :period, null: false
      t.references :user, index: true, foreign_key: true
      t.references :nonprofit, index: true, foreign_key: true
    end
  end
end
