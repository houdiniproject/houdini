# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignGiftsController < ApplicationController
  # post /campaign_gifts
  def create
    json_saved CreateCampaignGift.create campaign_gift_params
  end

  private

  def campaign_gift_params
    params.require(:campaign_gift).permit(:donation_id, :donation, :campaign_gift_option, :campaign_gift_option_id)
  end
end
