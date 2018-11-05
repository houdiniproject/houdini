# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignTemplate < ActiveRecord::Base
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
    :goal_customizable,
    :nonprofit_id

  attr_accessor :end_datetime
  attr_accessor :goal_amount_dollars

  has_many :campaigns
  belongs_to :nonprofit

  mount_uploader :main_image, CampaignTemplateMainImageUploader

  before_validation do
		if self.goal_amount_dollars.present?
			self.goal_amount = (self.goal_amount_dollars.gsub(',','').to_f * 100).to_i
		end
		self
	end

  def customizable_attribute?(attribute_name)
    CUSTOMIZABLE_ATTR.include? attribute_name.to_sym
  end

  def customizable_attributes_list
    CUSTOMIZABLE_ATTR
  end

  def create_campaign_params
    excluded = %w(
      id template_name created_at updated_at
    )
    attributes.except!(*excluded)
  end
end
