class AddFirstAndLastNameToSupporter < ActiveRecord::Migration
  def change
    add_column :supporters, :first_name, :string
    add_column :supporters, :last_name, :string
  end
end
