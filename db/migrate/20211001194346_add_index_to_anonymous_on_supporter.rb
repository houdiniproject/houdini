class AddIndexToAnonymousOnSupporter < ActiveRecord::Migration
  def change
    add_index :supporters, [:anonymous, :nonprofit_id]
  end
end
