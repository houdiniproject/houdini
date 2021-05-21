class AddPausingToMiscCampaignInfo < ActiveRecord::Migration
  def change
    add_column :misc_campaign_infos, :paused, :boolean, null: false, default: false
  end
end
