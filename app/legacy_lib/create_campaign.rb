# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreateCampaign
  CAMPAIGN_NAME_LENGTH_LIMIT = 60

  # @return [Object] a json object for historical purposes
  def self.create(params, nonprofit) # rubocop:disable Metrics/AbcSize
    Time.use_zone(nonprofit.timezone || "UTC") do
      params[:campaign][:end_datetime] = Chronic.parse(params[:end_datetime]) if params[:end_datetime].present?
    end

    if params[:campaign][:parent_campaign_id]
      profile_id = params[:campaign][:profile_id]
      Profile.find(profile_id).update params[:profile]
      CreatePeerToPeerCampaign.create(params[:campaign], profile_id)
    else
      nonprofit.campaigns.create! params[:campaign]

    end
  end
end
