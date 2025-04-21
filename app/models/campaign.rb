# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Campaign < ApplicationRecord
  include Image::AttachmentExtensions
  include Model::Jbuilder
  # :name,
  # :tagline,
  # :slug, # str: url name
  # :total_supporters,
  # :goal_amount,
  # :nonprofit_id,
  # :profile_id,
  # :main_image,
  # :remove_main_image, # for carrierwave
  # :background_image,
  # :remove_background_image, #bool carrierwave
  # :banner_image,
  # :remove_banner_image,
  # :published,
  # :video_url, #str
  # :vimeo_video_id,
  # :youtube_video_id,
  # :summary,
  # :body,
  # :goal_amount_dollars, #accessor: translated into goal_amount (cents)
  # :show_total_raised, # bool
  # :show_total_count, # bool
  # :hide_activity_feed, # bool
  # :end_datetime,
  # :deleted, #bool (soft delete)
  # :hide_goal, # bool
  # :hide_thermometer, #bool
  # :hide_title, # bool
  # :receipt_message, # text
  # :hide_custom_amounts, # boolean
  # :parent_campaign_id,
  # :reason_for_supporting,
  # :default_reason_for_supporting

  validate :end_datetime_cannot_be_in_past, on: :create
  validates :profile, presence: true
  validates :nonprofit, presence: true
  validates :goal_amount,
    presence: true,
    numericality: {only_integer: true, greater_than: 99}
  validates :name,
    presence: true,
    length: {maximum: 60}
  validates :slug, uniqueness: {scope: :nonprofit_id, message: "You already have a campaign with that URL."}, presence: true

  attr_accessor :goal_amount_dollars

  has_one_attached :main_image
  has_one_attached :background_image
  has_one_attached :banner_image

  has_one_attached_with_sizes(:main_image, {normal: [524, 360], thumb: [180, 150]})
  has_one_attached_with_sizes(:background_image, {normal: [1000, 600]})

  has_one_attached_with_default(:main_image, Houdini.defaults.image.profile,
    filename: "main_image_#{SecureRandom.uuid}#{Pathname.new(Houdini.defaults.image.profile).extname}")

  has_many :donations
  has_many :charges, through: :donations
  has_many :payments, through: :donations, source: "payment"
  has_many :campaign_gift_options
  has_many :campaign_gifts, through: :campaign_gift_options
  has_many :supporters, through: :donations
  has_many :recurring_donations
  has_many :campaign_gift_purchases
  has_many :roles, as: :host, dependent: :destroy
  has_many :activities, as: :host, dependent: :destroy
  belongs_to :profile
  belongs_to :nonprofit

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
    self
  end

  before_validation(on: :create) do
    self.slug = Format::Url.convert_to_slug(name) unless slug
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
    Houdini.event_publisher.announce(:campaign_create, self)
    self
  end

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

  def child_params
    excluded_for_peer_to_peer = %w[
      id created_at updated_at slug profile_id url
      total_raised show_recurring_amount external_identifier parent_campaign_id
      reason_for_supporting metadata
    ]
    attributes.except(*excluded_for_peer_to_peer)
  end

  def child_campaign?
    parent_campaign.present?
  end

  def parent_campaign?
    !child_campaign?
  end

  def self.get_campaign_and_children(campaign)
    where("campaigns.id = ? OR campaigns.parent_campaign_id = ? ", campaign, campaign)
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :name)

      json.add_builder_expansion :nonprofit
    end
  end
end
