class AddHideCoverFeesOptionInMiscCampaignInfos < ActiveRecord::Migration
  def change
    add_column :campaigns, :hide_cover_fees_option, :boolean
  end
end
