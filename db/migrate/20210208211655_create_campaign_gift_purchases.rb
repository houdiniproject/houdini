class CreateCampaignGiftPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :campaign_gift_purchases, id: :string do |t|
      t.boolean :deleted, null: false, default: false
      t.integer :amount, null: false
      t.references :campaign, foreign_key: true

      t.timestamps
    end
  end
end
