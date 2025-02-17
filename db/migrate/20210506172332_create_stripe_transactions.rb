class CreateStripeTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_transactions, id: :string do |t|
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
