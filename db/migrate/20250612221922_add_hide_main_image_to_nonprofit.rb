class AddHideMainImageToNonprofit < ActiveRecord::Migration[7.1]
  def change
    add_column :nonprofits, :hide_main_image, :boolean, default: false, null: false
  end
end
