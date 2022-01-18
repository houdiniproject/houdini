class AddNonprofitHouid < ActiveRecord::Migration
  def change
    add_column :nonprofits, :houid, :string, index: {unique: true}
  end
end
