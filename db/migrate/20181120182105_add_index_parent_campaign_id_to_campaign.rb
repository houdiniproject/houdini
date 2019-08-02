# frozen_string_literal: true

class AddIndexParentCampaignIdToCampaign < ActiveRecord::Migration
  def change
    add_index :campaigns, :parent_campaign_id
  end
end
