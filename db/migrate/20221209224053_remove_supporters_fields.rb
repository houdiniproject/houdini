class RemoveSupportersFields < ActiveRecord::Migration
  def change
    remove_column :supporters, :fields
  end
end
