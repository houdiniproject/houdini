class AddIndexToCampaignGifts < ActiveRecord::Migration
  def change
    add_index :campaign_gifts, :campaign_gift_option_id
  end
end
