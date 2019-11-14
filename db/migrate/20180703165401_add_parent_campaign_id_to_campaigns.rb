# frozen_string_literal: true

class AddParentCampaignIdToCampaigns < ActiveRecord::Migration[4.2]
  def change
    add_column :campaigns, :parent_campaign_id, :integer
  end
end
