# frozen_string_literal: true

class AddIndexToSupporterIdOnTickets < ActiveRecord::Migration
  def change
    add_index :tickets, :supporter_id
  end
end
