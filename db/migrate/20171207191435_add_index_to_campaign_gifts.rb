# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexToCampaignGifts < ActiveRecord::Migration[4.2]
  def change
    add_index :campaign_gifts, :campaign_gift_option_id
  end
end
