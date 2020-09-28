class AddRolesIndex < ActiveRecord::Migration
  def change
    add_index :roles, [:name, :user_id, :host_id]
  end
end
