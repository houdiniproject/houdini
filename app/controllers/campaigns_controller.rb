# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignsController < ApplicationController
  include Controllers::Campaign::Current
  include Controllers::Campaign::Authorization

  helper_method :current_campaign_editor?
  before_action :authenticate_confirmed_user!, only: %i[create name_and_id duplicate]
  before_action :authenticate_campaign_editor!, only: %i[update soft_delete]
  before_action :check_nonprofit_status, only: %i[index show]
  
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_rescue
  respond_to :json, only: :create

  def index
    @nonprofit = current_nonprofit
    if current_nonprofit_user?
      @campaigns = @nonprofit.campaigns.includes(:nonprofit).not_deleted.order('created_at desc')
      @deleted_campaigns = @nonprofit.campaigns.includes(:nonprofit).deleted.order('created_at desc')
    else
      @campaigns = @nonprofit.campaigns.includes(:nonprofit).not_deleted.not_a_child.order('created_at desc')
      @deleted_campaigns = @nonprofit.campaigns.includes(:nonprofit).deleted.not_a_child.order('created_at desc')
    end

    respond_to do |format|
      format.html do
        @active_campaigns = @campaigns.active
        @past_campaigns = @campaigns.past
        @unpublished_campaigns = @campaigns.unpublished
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

    @campaign_background_image = @campaign.background_image.attached? && url_for(@campaign.background_image_by_size(:normal))
  end

  def activities
    @campaign = current_campaign
    render json: QueryDonations.for_campaign_activities(@campaign.id)
  end

  def create
    @campaign = CreateCampaign.create(campaign_params, current_nonprofit)
    render 'campaigns/create', campaign: @campaign, status: :created
  end

  def update
    Time.use_zone(current_nonprofit.timezone || 'UTC') do
      campaign_params[:end_datetime] = Chronic.parse(campaign_params[:end_datetime]) if campaign_params[:end_datetime].present?
    end
    current_campaign.update campaign_params
    json_saved current_campaign, 'Successfully updated!'
  end

  # post 'nonprofits/:np_id/campaigns/:campaign_id/duplicate'
  def duplicate
    render_json do
      InsertDuplicate.campaign(current_campaign.id, current_user.profile.id)
    end
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
    session[:donor_signup_url] = request.env['REQUEST_URI']
    @nonprofit = Nonprofit.find_by_id(params[:npo_id])
    @parent_campaign = Campaign.find_by_id(params[:campaign_id])

    if params[:campaign_id].present? && !@parent_campaign
      raise ActionController::RoutingError, 'Not Found'
    end

    if current_user
      @profile = current_user.profile
      if @parent_campaign
        @child_campaign = Campaign.where(
          profile_id: @profile.id,
          parent_campaign_id: @parent_campaign.id
        ).first
      end
    end
  end

  private

  def check_nonprofit_status
    if !current_role?(:super_admin) && !current_nonprofit.published
      raise ActionController::RoutingError, 'Not Found'
    end
  end

  def campaign_params
    params.require(:campaign).permit(:name, :tagline, :slug, :total_supporters, :goal_amount, :nonprofit_id, :profile_id, :main_image, :remove_main_image, :background_image, :remove_background_image, :banner_image, :remove_banner_image, :published, :video_url, :vimeo_video_id, :youtube_video_id, :summary, :recurring_fund, :body, :goal_amount_dollars, :show_total_raised, :show_total_count, :hide_activity_feed, :end_datetime, :deleted, :hide_goal, :hide_thermometer, :hide_title, :receipt_message, :hide_custom_amounts, :parent_campaign_id, :reason_for_supporting, :default_reason_for_supporting)
  end

  def record_invalid_rescue(error)
    render json: { errors: error.record.errors.messages }, status: :unprocessable_entity
  end
end
