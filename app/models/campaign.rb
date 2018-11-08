# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Campaign < ActiveRecord::Base

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
		:remove_background_image, #bool carrierwave
    :banner_image,
    :remove_banner_image,
		:published,
		:video_url, #str
		:vimeo_video_id,
		:youtube_video_id,
		:summary,
		:recurring_fund, # bool: whether this is a recurring campaign
		:body,
		:goal_amount_dollars, #accessor: translated into goal_amount (cents)
		:show_total_raised, # bool
		:show_total_count, # bool
		:hide_activity_feed, # bool
    :end_datetime,
		:deleted, #bool (soft delete)
		:hide_goal, # bool
		:hide_thermometer, #bool
		:hide_title, # bool
    :receipt_message, # text
    :hide_custom_amounts, # boolean
    :parent_campaign_id,
    :reason_for_supporting,
    :default_reason_for_supporting

  validate  :end_datetime_cannot_be_in_past, :on => :create
	validates :profile, :presence => true
	validates :nonprofit, :presence => true
	validates :goal_amount,
		:presence => true,
		:numericality => {:only_integer => true, :greater_than => 99}
	validates :name,
		:presence => true,
		:length => {:maximum => 60}
  validates :slug, uniqueness: {scope: :nonprofit_id, message: 'You already have a campaign with that URL.'}, presence: true

  attr_accessor :goal_amount_dollars

	mount_uploader :main_image, CampaignMainImageUploader
	mount_uploader :background_image, CampaignBackgroundImageUploader
	mount_uploader :banner_image, CampaignBannerImageUploader

	has_many :donations
	has_many :charges, through: :donations
	has_many :payments, through: :donations
	has_many :campaign_gift_options
	has_many :campaign_gifts, through: :campaign_gift_options
	has_many :supporters, :through => :donations
	has_many :recurring_donations
	has_many :roles,        as: :host, dependent: :destroy
	has_many :comments,     as: :host, dependent: :destroy
	has_many :activities,   as: :host, dependent: :destroy
	belongs_to :profile
	belongs_to :nonprofit
  belongs_to :campaign_template

  belongs_to :parent_campaign, class_name: 'Campaign'
  has_many :children_campaigns, class_name: 'Campaign', foreign_key: 'parent_campaign_id'

	scope :published, ->   {where(:published => true)}
  scope :active, ->      {where(:published => true).where("end_datetime IS NULL OR end_datetime >= ?", Date.today)}
  scope :past, ->        {where(:published => true).where("end_datetime < ?", Date.today)}
	scope :unpublished, -> {where(:published => [nil, false])}
	scope :not_deleted, -> {where(deleted: [nil, false])}
	scope :deleted, -> {where(deleted: true)}

	before_validation do
		if self.goal_amount_dollars.present?
			self.goal_amount = (self.goal_amount_dollars.gsub(',','').to_f * 100).to_i
		end
		self
	end

	before_validation(on: :create) do
		unless self.slug
			self.slug = Format::Url.convert_to_slug(name)
		end
		self.set_defaults
		self
	end

	before_save do
		self.parse_video_id if self.video_url && self.video_url_changed?
		self
	end

	after_create do
		user = self.profile.user
		Role.create(name: :campaign_editor, user_id: user.id, host: self)
		CampaignMailer.delay.creation_followup(self)
		NonprofitAdminMailer.delay.supporter_fundraiser(self) unless QueryRoles.is_nonprofit_user?(user.id, self.nonprofit_id)
		self
	end

	def set_defaults

		self.total_supporters = 1
		self.published = false if self.published.nil?
	end


	def parse_video_id
		if self.video_url.include? 'vimeo'
			self.vimeo_video_id = self.video_url.split('/').last
			self.youtube_video_id = nil
		elsif self.video_url.include? 'youtube'
			match = self.video_url.match(/\?v=(.+)/)
			return if match.nil?
			self.youtube_video_id = match[1].split('&').first
			self.vimeo_video_id = nil
		elsif self.video_url.include? 'youtu.be'
			self.youtube_video_id = self.video_url.split('/').last
			self.vimeo_video_id = nil
		elsif self.video_url.blank?
			self.vimeo_video_id = nil
			self.youtube_video_id = nil
		end
		self
	end

	def total_raised
    self.payments.sum(:gross_amount)
	end

	def percentage_funded
		self.goal_amount.nil? ? 0 : self.total_raised * 100 / self.goal_amount
	end

	def average_donation
		self.donations.any? ? self.total_raised / self.donations.count : 0
	end

	# Validations

  def end_datetime_cannot_be_in_past
    if self.end_datetime.present? && self.end_datetime < Time.now
      errors.add(:end_datetime, "can't be in the past")
		end
	end

	def ready_to_publish?
		[(self.body && self.body.length >= 500), (self.campaign_gift_options.count >= 1)].all?
	end

	def url
		"#{self.nonprofit.url}/campaigns/#{self.slug}"
	end

	def days_left
    return 0 if self.end_datetime.nil?
    (self.end_datetime.to_date - Date.today).to_i
	end

  def customizable_attributes_list
    campaign_template.customizable_attributes_list if campaign_template
  end

  def child_params
    excluded_for_peer_to_peer = %w(
      id created_at updated_at slug profile_id campaign_template_id url
      total_raised show_recurring_amount external_identifier parent_campaign_id
      reason_for_supporting metadata
    )
    excluded_for_peer_to_peer.push(customizable_attributes_list)
    attributes.except(*excluded_for_peer_to_peer)
  end

  def child_campaign?
    if parent_campaign.present?
      true
    else
      false
    end
  end

  def parent_campaign?
    !child_campaign?
  end
end
