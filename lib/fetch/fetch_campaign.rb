# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchCampaign
  def self.with_params(params, nonprofit = nil)
    nonprofit ||= FetchNonprofit.with_params(params)
    if params[:campaign_slug]
      return nonprofit.campaigns.where(slug: params[:campaign_slug]).last
    elsif params[:campaign_id] || params[:id]
      return nonprofit.campaigns.find(params[:campaign_id] || params[:id])
    end
  end
end
