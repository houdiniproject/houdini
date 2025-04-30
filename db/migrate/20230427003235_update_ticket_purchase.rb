class UpdateTicketPurchase < ActiveRecord::Migration
  def change
    remove_column :ticket_purchases, :ticket_id

    add_reference :tickets, :ticket_purchase, index: true
  end
end
