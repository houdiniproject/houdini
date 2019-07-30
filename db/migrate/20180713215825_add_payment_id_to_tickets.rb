# frozen_string_literal: true

class AddPaymentIdToTickets < ActiveRecord::Migration
  def change
    add_index :tickets, :payment_id
  end
end
