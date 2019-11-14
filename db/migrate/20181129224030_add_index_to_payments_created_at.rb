# frozen_string_literal: true

class AddIndexToPaymentsCreatedAt < ActiveRecord::Migration[4.2]
  def change
    add_index :payments, :created_at
  end
end
