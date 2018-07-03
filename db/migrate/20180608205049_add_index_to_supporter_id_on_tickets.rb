class AddIndexToSupporterIdOnTickets < ActiveRecord::Migration
  def change
    add_index :tickets, :supporter_id
  end
end
