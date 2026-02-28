# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a nonprofit's supporters
class Api::CampaignGiftOptionsController < Api::ApiController
  include Controllers::Campaign::Current
  include Controllers::Campaign::Authorization

  before_action :authenticate_campaign_editor!

  def index
    @campaign_gift_options =
      current_campaign
        .campaign_gift_options
        .order("id DESC")
        .page(params[:page])
        .per(params[:per])
  end

  # If not logged in, causes a 401 error
  def show
    @campaign_gift_option = current_campaign.campaign_gift_options.find(params[:id])
  end
end
