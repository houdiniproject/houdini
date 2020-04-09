class RemoveSupportersDeletedIndex < ActiveRecord::Migration
  def change
    remove_index :supporters, :deleted
  end
end
