class AddUtmContentToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :utm_content, :string, unique: true
  end
end
