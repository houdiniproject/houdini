# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CreateCampaign
  CAMPAIGN_NAME_LENGTH_LIMIT = 60

  # @return [Object] a json object for historical purposes
  def self.create(params, nonprofit)
    Time.use_zone(nonprofit.timezone || 'UTC') do
      params[:campaign][:end_datetime] = Chronic.parse(params[:campaign][:end_datetime]) if params[:campaign][:end_datetime].present?
    end

    if !params[:campaign][:parent_campaign_id]
      campaign = nonprofit.campaigns.create params[:campaign]
      return campaign
    else
      profile_id = params[:campaign][:profile_id]
      Profile.find(profile_id).update params[:profile]
      return CreatePeerToPeerCampaign.create(params[:campaign], profile_id)
    end
  end
end
