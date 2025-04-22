# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CreatePeerToPeerCampaign
  def self.create(campaign_params, profile_id)
    begin
      parent_campaign = Campaign.find(campaign_params[:parent_campaign_id])
    rescue ActiveRecord::RecordNotFound
      return {errors: {parent_campaign_id: "not found"}}.as_json
    end

    p2p_params = campaign_params.except(:nonprofit_id, :summary, :goal_amount, :widget_description_id).to_deprecated_h
    p2p_params.merge!(parent_campaign.child_params)

    profile = Profile.find(profile_id)
    base_slug = Format::Url.convert_to_slug "#{p2p_params[:name]}-#{profile.name}"
    algo = SlugP2pCampaignNamingAlgorithm.new(p2p_params[:nonprofit_id])
    p2p_params[:slug] = algo.create_copy_name(base_slug)

    # child campaigns are always in dollars, not supporters
    p2p_params[:goal_is_in_supporters] = false

    campaign = Campaign.create(p2p_params)

    campaign.published = true
    campaign.profile = profile
    campaign.save

    begin
      campaign.update_attribute(:main_image, parent_campaign.main_image) unless !parent_campaign.main_image
    rescue
      Aws::S3::Errors::NoSuchKey
    end
    begin
      campaign.update_attribute(:background_image, parent_campaign.background_image) unless !parent_campaign.background_image
    rescue
      Aws::S3::Errors::NoSuchKey
    end
    begin
      campaign.update_attribute(:banner_image, parent_campaign.banner_image) unless !parent_campaign.banner_image
    rescue
      Aws::S3::Errors::NoSuchKey
    end

    return {errors: campaign.errors.messages}.as_json unless campaign.errors.empty?

    campaign.as_json
  end
end
