# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ModifySupportersNameIndex < ActiveRecord::Migration
  def up
    rename_index :supporters, :supporters_name, :supporters_lower_name
  end

  def down
    rename_index :supporters, :supporters_lower_name, :supporters_name
  end
end
