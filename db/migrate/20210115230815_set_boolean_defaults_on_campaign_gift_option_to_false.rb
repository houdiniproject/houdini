# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SetBooleanDefaultsOnCampaignGiftOptionToFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :campaign_gift_options, :to_ship, from: nil, to: false
    change_column_null :campaign_gift_options, :to_ship, false

    change_column_default :campaign_gift_options, :hide_contributions, from: nil, to: false
    change_column_null :campaign_gift_options, :hide_contributions, false
  end
end
