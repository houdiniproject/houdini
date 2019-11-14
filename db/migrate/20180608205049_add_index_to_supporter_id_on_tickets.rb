# frozen_string_literal: true

class AddIndexToSupporterIdOnTickets < ActiveRecord::Migration[4.2]
  def change
    add_index :tickets, :supporter_id
  end
end
