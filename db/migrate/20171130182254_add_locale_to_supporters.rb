class AddLocaleToSupporters < ActiveRecord::Migration
  def change
    add_column :supporters, :locale, :string
  end
end
