# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddInactiveToCard < ActiveRecord::Migration
  class Card < ActiveRecord::Base
    attr_accessible :inactive
  end

  def change
    add_column :cards, :inactive, :boolean

    add_index :cards, [:id, :holder_type, :holder_id, :inactive] # add index for getting active_card
    Card.reset_column_information
    Card.update_all(inactive: false)
  end
end
