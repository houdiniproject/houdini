class ChangeAnonymousDefaultFromSupporters < ActiveRecord::Migration
  def change
    change_column_default :supporters, :anonymous, false
  end
end
