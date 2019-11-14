# frozen_string_literal: true

class AddIndexesToRefunds < ActiveRecord::Migration[4.2]
  def change
    add_index :refunds, :payment_id
  end
end
