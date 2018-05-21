module Nonprofits
  class CampaignTemplatesController < ApplicationController
    include NonprofitHelper

    before_filter :authenticate_nonprofit_admin!, only: :create
  	before_filter :authenticate_nonprofit_user!, only: [:index, :show]

    def index
      @nonprofit = current_nonprofit
      @templates = @nonprofit.campaign_templates
    end

    def create
      template = CampaignTemplate.create(params[:campaign_template])

      json_saved template
    end

    def destroy
      campaign = CampaignTemplate.find(params[:id])
      campaign.destroy

      render json: {}, status: :no_content
    end
  end
end
