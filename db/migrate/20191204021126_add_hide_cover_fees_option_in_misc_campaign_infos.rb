class AddHideCoverFeesOptionInMiscCampaignInfos < ActiveRecord::Migration
  def change
    add_column :misc_campaign_infos, :hide_cover_fees_option, :boolean
  end
end
