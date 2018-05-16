module Nonprofits
  class CampaignTemplatesController < ApplicationController
    include NonprofitHelper

    before_filter :authenticate_nonprofit_admin!, only: :create
  	before_filter :authenticate_nonprofit_user!, only: [:index, :show]

    def index
      @templates = CampaignTemplate.all
    end

    def create
      puts params

      render :status_ok
    end
  end
end
