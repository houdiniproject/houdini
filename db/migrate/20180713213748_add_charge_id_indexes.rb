# frozen_string_literal: true

class AddChargeIdIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :refunds, :charge_id
  end
end
