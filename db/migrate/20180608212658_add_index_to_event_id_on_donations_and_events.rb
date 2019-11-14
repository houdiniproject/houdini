# frozen_string_literal: true

class AddIndexToEventIdOnDonationsAndEvents < ActiveRecord::Migration[4.2]
  def change
    add_index :tickets, :event_id
    add_index :donations, :event_id
  end
end
