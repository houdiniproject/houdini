class MakeAnonymousFromSupportersNotNullable < ActiveRecord::Migration
  def change
    change_column_null :supporters, :anonymous, false
  end
end
