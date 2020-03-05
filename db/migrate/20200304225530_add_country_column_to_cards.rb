class AddCountryColumnToCards < ActiveRecord::Migration
  def change
    add_column :cards, :country, :string
  end
end
