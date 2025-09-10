class AddTimezoneToEvents < ActiveRecord::Migration[7.1]
  def change
    change_table :events do |t|
      t.string :timezone
    end
  end
end
