class AddCustomLayoutToNonprofit < ActiveRecord::Migration
  def change
    add_column :nonprofits, :custom_layout, :string
  end
end
