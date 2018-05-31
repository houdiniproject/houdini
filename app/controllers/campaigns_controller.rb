# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignsController < ApplicationController
  include Controllers::CampaignHelper

  helper_method :current_campaign_editor?
  before_filter :authenticate_confirmed_user!, only: [:create, :name_and_id, :duplicate]
  before_filter :authenticate_campaign_editor!, only: [:update, :soft_delete]
  before_filter :check_nonprofit_status, only: [:index, :show]

  def index
    @nonprofit = current_nonprofit
    @campaigns = @nonprofit.campaigns.includes(:nonprofit).not_deleted.order('created_at desc')

    respond_to do |format|
      format.html do
        @active_campaigns = @campaigns.active
        @past_campaigns = @campaigns.past
        @unpublished_campaigns = @campaigns.unpublished
        @deleted_campaigns = @nonprofit.campaigns.deleted.order('created_at desc')
      end

      format.json do
        @campaigns = @campaigns.limit(params[:limit]) unless params[:limit].blank?
      end
    end
  end

  def show
    @campaign = current_campaign
    @timezone = Format::Timezone.to_proxy(current_nonprofit.timezone)
    if @campaign.deleted && !current_campaign_editor?
      redirect_to nonprofit_path(current_nonprofit)
      flash[:notice] = "Sorry, we couldn't find that campaign"
      return
    end
    @nonprofit = current_nonprofit
    @url = Format::Url.concat(root_url, @campaign.url)

    if @campaign.child_campaign?
      @parent_campaign = @campaign.parent_campaign
      @peer_to_peer_campaign_param = @parent_campaign.id
    else
      @peer_to_peer_campaign_param = @campaign.id
    end

    @campaign_background_image = FetchBackgroundImage.with_model(@campaign)
  end

  def activities
    render json: QueryDonations.for_campaign_activities(params[:id])
  end

  def create
    Time.use_zone(current_nonprofit.timezone || 'UTC') do
      params[:campaign][:end_datetime] = Chronic.parse(params[:campaign][:end_datetime]) if params[:campaign][:end_datetime].present?
    end

    if !params[:campaign][:parent_campaign_id]
      campaign = current_nonprofit.campaigns.create params[:campaign]
    else
      profile_id = params[:campaign][:profile_id]
      Profile.find(profile_id).update_attributes params[:profile]
      campaign = create_peer_to_peer_campaign params[:campaign], profile_id
    end

    json_saved campaign, 'Campaign created! Well done.'
  end

  def update
    Time.use_zone(current_nonprofit.timezone || 'UTC') do
      params[:campaign][:end_datetime] = Chronic.parse(params[:campaign][:end_datetime]) if params[:campaign][:end_datetime].present?
    end
    current_campaign.update_attributes params[:campaign]
    json_saved current_campaign, 'Successfully updated!'
  end


  # post 'nonprofits/:np_id/campaigns/:campaign_id/duplicate'
  def duplicate

    render_json {
      InsertDuplicate.campaign(current_campaign.id, current_user.profile.id)
    }

  end


  def soft_delete
    current_campaign.update_attribute(:deleted, params[:delete])
    render json: {}
  end

  def metrics
    render json: QueryCampaignMetrics.on_donations(current_campaign.id)
  end

  def timeline
    render json: QueryCampaigns.timeline(current_campaign.id)
  end

  # returns supporters count as well as total cents for one time, recurring, offsite and the previous three combined. used on campaign dashboard
  def totals
    render json: QueryCampaigns.totals(current_campaign.id)
  end

  def name_and_id
    render json: QueryCampaigns.name_and_id(current_nonprofit.id)
  end

  def peer_to_peer
    session[:donor_signup_url] = request.env["REQUEST_URI"]
    @nonprofit = Nonprofit.find_by_id(params[:npo_id])
    @parent_campaign = Campaign.find_by_id(params[:campaign_id])
    @child_campaign = Campaign.where(
      profile_id: current_user.profile.id,
      parent_campaign_id: @parent_campaign.id
    ).first if @parent_campaign
    @profile = current_user.profile if current_user
  end

  private

  def check_nonprofit_status
    if !current_role?(:super_admin) && !current_nonprofit.published
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  # TODO: refactor
  def create_peer_to_peer_campaign(params, profile_id)
    parent_campaign = Campaign.find(params[:parent_campaign_id])
    profile = Profile.find(profile_id)

    p2p_params = params.except(:nonprofit_id, :summary,:goal_amount)
    p2p_params.merge!(parent_campaign.child_params)

    base_slug = Format::Url.convert_to_slug "#{p2p_params[:name]}-#{profile.name}"
    algo = SlugP2pCampaignNamingAlgorithm.new(p2p_params[:nonprofit_id])
    p2p_params[:slug]  = algo.create_copy_name(base_slug)

    campaign = Campaign.create(p2p_params)

    # campaign.remote_main_image_url = parent_campaign.main_image_url unless !parent_campaign.main_image rescue AWS::S3::Errors::NoSuchKey
    # campaign.remote_background_image_url = parent_campaign.background_image_url unless !parent_campaign.background_image rescue AWS::S3::Errors::NoSuchKey
    # campaign.remote_banner_image_url = parent_campaign.background_image_url unless !parent_campaign.background_image rescue AWS::S3::Errors::NoSuchKey

    campaign.published = true
    campaign.save

    return campaign unless campaign.errors.empty?

    gift_option_params = []
    parent_campaign.campaign_gift_options.each do |option|
      excluded_for_peer_to_peer = %w(id campaign_id created_at updated_at)
      campaign.campaign_gift_options.create option.attributes.except(*excluded_for_peer_to_peer)
    end

    campaign
  end
end
