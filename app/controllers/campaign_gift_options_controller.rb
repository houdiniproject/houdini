# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignGiftOptionsController < ApplicationController
  include Controllers::Campaign::Current
  include Controllers::Campaign::Authorization

  before_action :authenticate_campaign_editor!, only: %i[create destroy update update_order]

  def index
    @gift_options = current_campaign.campaign_gift_options.order('"order", amount_recurring, amount_one_time')
    render json: { data: @gift_options }
  end

  def show
    render json: { data: current_campaign.campaign_gift_options.find(params[:id]) }
  end

  def create
    campaign = current_campaign
    json_saved CreateCampaignGiftOption.create(campaign, campaign_gift_option_params),
               'Gift option successfully created!'
  end

  def update
    @campaign = current_campaign
    gift_option = @campaign.campaign_gift_options.find params[:id]
    json_saved UpdateCampaignGiftOption.update(gift_option, campaign_gift_option_params), 'Successfully updated'
  end

  # put /nonprofits/:nonprofit_id/campaigns/:campaign_id/campaign_gift_options/update_order
  # Pass in {data: [{id: 1, order: 1}]}
  def update_order
    updated_gift_options = UpdateOrder.with_data('campaign_gift_options', params[:data])
    render json: updated_gift_options
  end

  def destroy
    @campaign = current_campaign

    render_json { DeleteCampaignGiftOption.delete(@campaign, params[:id]) }
  end

  private

  def campaign_gift_option_params
    params.require(:campaign_gift_option).permit(:amount_one_time, :amount_recurring, :amount_dollars, :description, :name, :campaign, :quantity, :to_ship, :order, :hide_contributions)
  end
end
