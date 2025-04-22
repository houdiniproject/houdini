# from upstream houdini

class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :supporter, index: true
      t.string :houid, null: false, index: {unique: true}
      t.integer :amount
      t.datetime :created, index: {order: :desc}
      t.timestamps
    end
  end
end
