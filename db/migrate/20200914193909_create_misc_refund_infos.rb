class CreateMiscRefundInfos < ActiveRecord::Migration
  def change
    create_table :misc_refund_infos do |t|
      t.boolean :is_modern
      t.string :stripe_application_fee_refund_id
      t.references :refund
      t.timestamps
    end
  end
end
