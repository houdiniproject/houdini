class AddIndexForSupporterIdOnCustomFieldJoins < ActiveRecord::Migration
  def change
    add_index :custom_field_joins, :supporter_id
  end
end
