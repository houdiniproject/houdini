class AddCurrencyToNonprofit < ActiveRecord::Migration
  def change
    add_column :nonprofits, :currency, :string, default: Settings.intntl.currencies[0]
  end
end
