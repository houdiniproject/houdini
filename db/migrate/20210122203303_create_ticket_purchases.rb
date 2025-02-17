class CreateTicketPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :ticket_purchases, id: :string do |t|
      t.integer :amount
      t.integer :original_discount, default: 0
      t.references :event_discount, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end

    create_table :transaction_assignments, id: :string do |t|
      t.references :transaction, foreign_key: true, type: :string, null: false
      t.references :assignable, polymorphic: true, type: :string, index: {unique: true}, null: false
    end
  end
end
