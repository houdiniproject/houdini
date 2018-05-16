class AddParentCampaignIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :parent_campaign_id, :integer
  end
end
