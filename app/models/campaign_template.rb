class CampaignTemplate < ActiveRecord::Base
  # these are very arbitrary names – some are attrs of campaign, some are not
  # might be a good idea to get the default list from settings
  CUSTOMIZABLE_ATTR = %i(goal_amount)

  attr_accessible \
    :template_name,
		:name, # refers to campaign name
		:tagline,
		:goal_amount,
    :goal_amount_dollars, # accessor: translated into goal_amount (cents)
		:main_image,
		:remove_main_image, # for carrierwave
		:video_url,
		:vimeo_video_id,
		:youtube_video_id,
		:summary,
		:body,
    :end_datetime,
    :goal_customizable

  attr_accessor :goal_amount_dollars
  attr_accessor :goal_customizable
  attr_accessor :end_datetime
  attr_accessor :hide_activity_feed
  attr_accessor :deleted
  attr_accessor :hide_title
  attr_accessor :slug
  attr_accessor :custom_banner_url
  attr_accessor :published
  attr_accessor :show_total_raised
  attr_accessor :show_total_count
  attr_accessor :hide_goal
  attr_accessor :hide_thermometer
  attr_accessor :hide_custom_amounts
  attr_accessor :receipt_message

  has_many :campaigns
  belongs_to :nonprofit

  def customizable_attribute?(attribute_name)
    CUSTOMIZABLE_ATTR.include? attribute_name.to_sym
  end

  def recurring_fund?
  end

  def main_image_url(url)
  end

  def slug
    Format::Url.convert_to_slug(template_name)
  end

  def customizable_attributes_list
    CUSTOMIZABLE_ATTR
  end

  def name
    if self[:name]
      self[:name]
    else
      'no name'
    end
  end

  def url
		"#{self.nonprofit.url}/campaigns/#{self.slug}"
	end

  def days_left
    return 0 if self.end_datetime.nil?
    (self.end_datetime.to_date - Date.today).to_i
  end

  before_validation do
		if self.goal_amount_dollars.present?
			self.goal_amount = (self.goal_amount_dollars.gsub(',','').to_f * 100).to_i
		end
		self
	end

  after_create do
		# user = self.profile.user
		# Role.create(name: :campaign_editor, user_id: user.id, host: self)
  end

  before_validation(on: :create) do
		self.set_defaults
		self
	end

  def set_defaults
    # self.total_supporters = 1
    # self.published = false if self.published.nil?
  end
end
