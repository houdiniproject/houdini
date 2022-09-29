class CreateManualBalanceAdjustments < ActiveRecord::Migration
  def change
    create_table :manual_balance_adjustments do |t|
      t.integer :gross_amount, default: 0
      t.integer :fee_total, default: 0
      t.integer :net_amount, default: 0
      t.belongs_to :payment
      t.belongs_to :entity, polymorphic: true
      t.text :staff_comment
      t.boolean :disbursed, default: false
      t.jsonb :metadata

      t.timestamps null: false
    end
  end
end
