class AddRequireTwoFactorToNonprofits < ActiveRecord::Migration[7.1]
  def change
    add_column :nonprofits, :require_two_factor, :boolean, default: false, null: false
  end
end
