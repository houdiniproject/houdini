class CreateModernCampaignGifts < ActiveRecord::Migration[6.1]
  def change
    create_table :modern_campaign_gifts, id: :string do |t|
      t.boolean :deleted, null: false, default: false
      t.references :campaign_gift, null: false, foreign_key: true
      t.integer :amount, null: false, default: 0
      t.references :campaign_gift_purchase, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
