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

      #do notifications
      user = campaign.profile.user
      Role.create(name: :campaign_editor, user_id: user.id, host: self)
      CampaignMailer.delay.creation_followup(self)
      NonprofitAdminMailer.delay.supporter_fundraiser(self) unless QueryRoles.is_nonprofit_user?(user.id, self.nonprofit_id)

      return { errors: campaign.errors.messages }.as_json unless campaign.errors.empty?
      return campaign.as_json
      #json_saved campaign, 'Campaign created! Well done.'
    else
      profile_id = params[:campaign][:profile_id]
      Profile.find(profile_id).update_attributes params[:profile]
      return CreatePeerToPeerCampaign.create(params[:campaign], profile_id)
    end
  end



end