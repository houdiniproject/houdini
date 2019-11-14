# frozen_string_literal: true

class AddPaymentIdToTickets < ActiveRecord::Migration[4.2]
  def change
    add_index :tickets, :payment_id
  end
end
