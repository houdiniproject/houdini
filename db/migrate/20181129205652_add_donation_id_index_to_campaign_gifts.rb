# frozen_string_literal: true

class AddDonationIdIndexToCampaignGifts < ActiveRecord::Migration[4.2]
  def change
    add_index :campaign_gifts, :donation_id
  end
end
