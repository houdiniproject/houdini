# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
