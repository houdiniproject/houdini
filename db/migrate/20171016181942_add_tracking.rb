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
