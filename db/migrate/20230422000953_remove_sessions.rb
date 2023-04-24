class RemoveSessions < ActiveRecord::Migration
  def change
    if table_exists? :sessions
      drop_table :sessions
    end
  end
end
