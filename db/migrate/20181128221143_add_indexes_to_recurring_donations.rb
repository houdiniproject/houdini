# frozen_string_literal: true

class AddIndexesToRecurringDonations < ActiveRecord::Migration[4.2]
  def change
    add_index :recurring_donations, :donation_id
  end
end
