# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Campaign < ApplicationRecord
  attr_accessible \
    :name,
    :tagline,
    :slug, # str: url name
    :total_supporters,
    :goal_amount,
    :nonprofit_id,
    :profile_id,
    :main_image,
    :remove_main_image, # for carrierwave
    :background_image,
    :remove_background_image, # bool carrierwave
    :banner_image,
    :remove_banner_image,
    :published,
    :video_url, # str
    :vimeo_video_id,
    :youtube_video_id,
    :summary,
    :body,
    :goal_amount_dollars, # accessor: translated into goal_amount (cents)
    :show_total_raised, # bool
    :show_total_count, # bool
    :hide_activity_feed, # bool
    :end_datetime,
    :deleted, # bool (soft delete)
    :hide_goal, # bool
    :hide_thermometer, # bool
    :hide_title, # bool
    :receipt_message, # text
    :hide_custom_amounts, # boolean
    :parent_campaign_id,
    :reason_for_supporting,
    :default_reason_for_supporting

  validate :end_datetime_cannot_be_in_past, on: :create
  validates :profile, presence: true
  validates :nonprofit, presence: true
  validates :goal_amount,
    presence: true, numericality: {
      only_integer: true
    }
  validate :validate_goal_amount
  validates :name,
    presence: true,
    length: {maximum: 60}
  validates :slug, uniqueness: {scope: :nonprofit_id, message: "You already have a campaign with that URL."}, presence: true

  validates :starting_point, presence: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}

  attr_accessor :goal_amount_dollars

  attr_accessible :starting_point, # integer, number of donors to start with
    :goal_is_in_supporters # boolean, true if you want to measure success based on donors instead of amount

  mount_uploader :main_image, CampaignMainImageUploader
  mount_uploader :background_image, CampaignBackgroundImageUploader
  mount_uploader :banner_image, CampaignBannerImageUploader

  has_many :donations
  ## we already have a recurring_donations relationship but it's broken so we'll create one here just as a workaround
  has_many :valid_rds, through: :donations, source: :recurring_donation, class_name: "RecurringDonation"
  has_many :charges, through: :donations
  has_many :payments, through: :donations, source: :payment
  has_many :campaign_gift_options
  has_many :campaign_gifts, through: :campaign_gift_options
  has_many :supporters, through: :donations
  has_many :recurring_donations
  has_many :roles, as: :host, dependent: :destroy
  has_many :activities, as: :host, dependent: :destroy
  belongs_to :profile
  belongs_to :nonprofit
  has_one :misc_campaign_info, dependent: :destroy
  belongs_to :widget_description

  belongs_to :parent_campaign, class_name: "Campaign"
  has_many :children_campaigns, class_name: "Campaign", foreign_key: "parent_campaign_id"

  scope :published, -> { where(published: true) }
  scope :active, -> { where(published: true).where("end_datetime IS NULL OR end_datetime >= ?", Date.today) }
  scope :past, -> { where(published: true).where("end_datetime < ?", Date.today) }
  scope :unpublished, -> { where(published: [nil, false]) }
  scope :not_deleted, -> { where(deleted: [nil, false]) }
  scope :deleted, -> { where(deleted: true) }
  scope :not_a_child, -> { where(parent_campaign_id: nil) }

  before_validation do
    if goal_amount_dollars.present?
      self.goal_amount = (goal_amount_dollars.delete(",").to_f * 100).to_i
    end

    unless starting_point
      self.starting_point = 0
    end
    self
  end

  before_validation(on: :create) do
    unless slug
      self.slug = Format::Url.convert_to_slug(name)
    end
    set_defaults
    self
  end

  before_save do
    parse_video_id if video_url && video_url_changed?
    self
  end

  after_create do
    user = profile.user
    Role.create(name: :campaign_editor, user_id: user.id, host: self)
    if child_campaign?
      CampaignMailer.delay.federated_creation_followup(self)
    else
      CampaignMailer.delay.creation_followup(self)
    end

    NonprofitAdminMailer.delay.supporter_fundraiser(self) unless QueryRoles.is_nonprofit_user?(user.id, nonprofit_id)
    self
  end

  after_update :send_campaign_updated

  def set_defaults
    self.total_supporters = 1
    self.published = false if published.nil?
  end

  def parse_video_id
    if video_url.include? "vimeo"
      self.vimeo_video_id = video_url.split("/").last
      self.youtube_video_id = nil
    elsif video_url.include? "youtube"
      match = video_url.match(/\?v=(.+)/)
      return if match.nil?
      self.youtube_video_id = match[1].split("&").first
      self.vimeo_video_id = nil
    elsif video_url.include? "youtu.be"
      self.youtube_video_id = video_url.split("/").last
      self.vimeo_video_id = nil
    elsif video_url.blank?
      self.vimeo_video_id = nil
      self.youtube_video_id = nil
    end
    self
  end

  def total_raised
    payments.sum(:gross_amount)
  end

  def percentage_funded
    goal_amount.nil? ? 0 : total_raised * 100 / goal_amount
  end

  def average_donation
    donations.any? ? total_raised / donations.count : 0
  end

  # Validations

  def end_datetime_cannot_be_in_past
    if end_datetime.present? && end_datetime < Time.now
      errors.add(:end_datetime, "can't be in the past")
    end
  end

  def ready_to_publish?
    [body && body.length >= 500, (campaign_gift_options.count >= 1)].all?
  end

  def url
    "#{nonprofit.url}/campaigns/#{slug}"
  end

  def days_left
    return 0 if end_datetime.nil?
    (end_datetime.to_date - Date.today).to_i
  end

  def finished?
    end_datetime && end_datetime < Time.now
  end

  def validate_goal_amount
    goal_amount = self.goal_amount || 0
    if goal_is_in_supporters
      if goal_amount < 1
        errors.add(:goal_amount, "must be greater than or equal to 1")
      end
    elsif goal_amount < 99
      errors.add(:goal_amount, "must be greater than or equal to 99 cents")
    end
  end

  def child_params
    excluded_for_peer_to_peer = %w[
      id created_at updated_at slug profile_id url
      total_raised show_recurring_amount external_identifier parent_campaign_id
      reason_for_supporting metadata goal_is_in_supporters
      widget_description_id
    ]
    attributes.except(*excluded_for_peer_to_peer)
  end

  def child_campaign?
    parent_campaign.present?
  end

  def parent_campaign?
    !child_campaign?
  end

  def params_to_copy_from_parent
    params = %w[
      tagline body video_url receipt_message youtube_video_id summary name
    ]

    parent_campaign.attributes.slice(*params)
  end

  def update_from_parent!
    if child_campaign?
      params_to_copy_from_parent.each do |k, v|
        update_attribute(k, v)
      end
      [:main_image, :background_image, :banner_image].each do |i|
        if parent_campaign.send("#{i}?")
          begin
            update_attribute(i, parent_campaign.send(i)) unless !parent_campaign.send(i.to_s)
          rescue
            Aws::S3::Errors::NoSuchKey
          end
        else
          send("remove_#{i}!")
        end
      end
      save!
    end
  end

  def self.get_campaign_and_children(campaign)
    where("campaigns.id = ? OR campaigns.parent_campaign_id = ? ", campaign, campaign)
  end

  def hide_cover_fees?
    nonprofit.hide_cover_fees? || misc_campaign_info&.hide_cover_fees_option
  end

  def fee_coverage_option
    @fee_coverage_option ||= misc_campaign_info&.fee_coverage_option_config || nonprofit.fee_coverage_option
  end

  # generally, don't use
  attr_writer :fee_coverage_option

  def paused?
    !!misc_campaign_info&.paused
  end

  def send_campaign_updated
    JobQueue.queue(JobTypes::CampaignUpdatedJob, id)
  end
end
