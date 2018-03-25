# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddTracking < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.column :utm_campaign, :string, unique: true
      t.column :utm_medium, :string, unique: true
      t.column :utm_source, :string, unique: true
      t.belongs_to :donation, index: true
      t.timestamps
    end
  end
end
