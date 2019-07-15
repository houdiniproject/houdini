class CreateTicketOrders < ActiveRecord::Migration
  def change
    create_table :ticket_orders do |t| 
      t.timestamps
      t.references :supporter
    end

    add_column :tickets, :ticket_order_id, :integer
    add_index :tickets, :ticket_order_id
  end
end
