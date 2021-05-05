class CreateStripeCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_charges, id: :string do |t|
      t.references :payment, foreign_key: true, id: :string

      t.timestamps
    end
  end
end
