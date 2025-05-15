class AddSupporterHouid < ActiveRecord::Migration
  def change
    add_column :supporters, :houid, :string
    add_index :supporters, :houid, unique: true
  end
end
