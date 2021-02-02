class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions, id: :string do |t|
      t.references :supporter, foreign_key: true
      t.integer :amount
      t.timestamps
    end
  end
end
