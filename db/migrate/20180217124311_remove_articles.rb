# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemoveArticles < ActiveRecord::Migration
  def up
    drop_table :articles
  end

  def down
  end
end
