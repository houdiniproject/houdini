# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module FetchCampaign
  def self.with_params(params, nonprofit = nil)
    nonprofit ||= FetchNonprofit.with_params(params)
    if params[:campaign_slug]
      nonprofit.campaigns.where(slug: params[:campaign_slug]).last
    elsif params[:campaign_id] || params[:id]
      nonprofit.campaigns.find(params[:campaign_id] || params[:id])
    end
  end
end
