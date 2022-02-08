class RemovePrimaryAddressForeignKey < ActiveRecord::Migration
  def change
    remove_foreign_key :supporters, column: :primary_address_id
  end
end
