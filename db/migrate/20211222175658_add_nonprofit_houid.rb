class AddNonprofitHouid < ActiveRecord::Migration
  def change
    add_column :nonprofits, :houid, :string
    add_index :nonprofits, :houid, unique: true
  end
end
