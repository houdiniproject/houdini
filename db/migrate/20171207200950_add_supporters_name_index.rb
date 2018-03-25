class AddSupportersNameIndex < ActiveRecord::Migration
  def change
    add_index :supporters, :name
  end
end
