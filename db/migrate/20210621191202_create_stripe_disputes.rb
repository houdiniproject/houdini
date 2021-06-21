class CreateStripeDisputes < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_disputes, id: :string do |t|
      t.references :payment, foreign_key: true, id: :string

      t.timestamps
    end
  end
end
