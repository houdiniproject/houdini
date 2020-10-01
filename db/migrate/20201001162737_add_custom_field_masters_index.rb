class AddCustomFieldMastersIndex < ActiveRecord::Migration
  def change
    add_index :custom_field_masters, :nonprofit_id
  end
end
