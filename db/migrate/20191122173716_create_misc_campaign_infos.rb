class CreateMiscCampaignInfos < ActiveRecord::Migration
  def change
    create_table :misc_campaign_infos do |t|
      t.timestamps
      t.references :campaign
      t.boolean :manual_cover_fees
    end

    add_index :misc_campaign_infos, :campaign_id
  end
end
