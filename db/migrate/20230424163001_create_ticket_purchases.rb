# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

class CreateTicketPurchases < ActiveRecord::Migration
  def change
    create_table :ticket_purchases do |t|
      t.string "houid", null: false
      t.references :ticket

      t.timestamps null: false
    end
  end
end
