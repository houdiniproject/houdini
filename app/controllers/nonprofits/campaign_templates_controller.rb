# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class CampaignTemplatesController < ApplicationController
    include Controllers::NonprofitHelper

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
