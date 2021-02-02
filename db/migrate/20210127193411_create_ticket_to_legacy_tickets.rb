# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CreateTicketToLegacyTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :ticket_to_legacy_tickets, id: :string do |t|
      t.references :ticket_purchase, foreign_key: true, type: :string
      t.references :ticket, foreign_key: true
      t.integer :amount, default: 0

      t.timestamps
    end
  end
end
