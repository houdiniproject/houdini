class CreatePaymentImports < ActiveRecord::Migration
  def change
    create_table :payment_imports do |t|
      t.references :user
      t.references :nonprofit

      t.timestamps
    end
  end
end
