# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreatePeerToPeerCampaign
  def self.create(campaign_params, profile_id) # rubocop:disable Metrics/AbcSize
    parent_campaign = Campaign.find(campaign_params[:parent_campaign_id])

    p2p_params = campaign_params.except(:nonprofit_id, :summary, :goal_amount)
    p2p_params.merge!(parent_campaign.child_params)

    profile = Profile.find(profile_id)
    base_slug = Format::Url.convert_to_slug "#{p2p_params[:name]}-#{profile.name}"
    algo = SlugP2pCampaignNamingAlgorithm.new(p2p_params[:nonprofit_id])
    p2p_params[:slug] = algo.create_copy_name(base_slug)

    campaign = Campaign.create!(**p2p_params, profile: profile)

    campaign.published = true
    campaign.profile = profile
    campaign.save
    campaign.main_image.attach(parent_campaign.main_image.blob) if parent_campaign.main_image.attached?

    campaign.background_image.attach(parent_campaign.background_image.blob) if parent_campaign.background_image.attached?

    campaign.banner_image.attach(parent_campaign.banner_image.blob) if parent_campaign.banner_image.attached?

    campaign
  end
end
