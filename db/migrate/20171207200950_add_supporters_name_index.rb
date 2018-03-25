# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddSupportersNameIndex < ActiveRecord::Migration
  def change
    add_index :supporters, :name
  end
end
