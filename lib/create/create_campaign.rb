# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module CreateCampaign
  CAMPAIGN_NAME_LENGTH_LIMIT = 60

  # @return [Object] a json object for historical purposes
  def self.create(params, nonprofit)
    Time.use_zone(nonprofit.timezone || 'UTC') do
      params[:end_datetime] = Chronic.parse(params[:end_datetime]) if params[:end_datetime].present?
    end

    if !params[:parent_campaign_id]
      campaign = nonprofit.campaigns.create! params
      return campaign
    else
      profile_id = params[:profile_id]
      Profile.find(profile_id).update params[:profile]
      return CreatePeerToPeerCampaign.create(params, profile_id)
    end
  end
end
