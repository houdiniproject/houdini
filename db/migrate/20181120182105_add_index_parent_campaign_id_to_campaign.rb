# frozen_string_literal: true

class AddIndexParentCampaignIdToCampaign < ActiveRecord::Migration[4.2]
  def change
    add_index :campaigns, :parent_campaign_id
  end
end
