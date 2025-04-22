# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Campaigns
  class SupportersController < ApplicationController
    include Controllers::Campaign::Current
    include Controllers::Campaign::Authorization

    before_action :authenticate_campaign_editor!, only: [:index]

    def index
      @panels_layout = true
      @nonprofit = current_nonprofit
      @campaign = current_campaign

      respond_to do |format|
        format.json do
          render json: QuerySupporters.campaign_list(@nonprofit.id, @campaign.id, params)
        end
        format.html
      end
    end
  end
end
