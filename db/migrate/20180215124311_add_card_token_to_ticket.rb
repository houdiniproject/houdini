# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddCardTokenToTicket < ActiveRecord::Migration
  def up
    add_column :tickets, :source_token_id, "uuid"
  end

  def down
    remove_column :tickets, :source_token_id
  end
end
