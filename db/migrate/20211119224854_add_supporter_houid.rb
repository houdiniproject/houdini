class AddSupporterHouid < ActiveRecord::Migration
  def change
    add_column :supporters, :houid, :string, index: {unique: true}
  end
end
