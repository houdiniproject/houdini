class AddIndexToAnonymousOnSupporter < ActiveRecord::Migration
  def change
    add_index :supporters, :anonymous
  end
end
