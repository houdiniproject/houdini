class CampaignTemplate < ActiveRecord::Base
  # these are very arbitrary names – some are attrs of campaign, some are not
  # might be a good idea to get the default list from settings
  CUSTOMIZABLE_ATTR = %i(goal_amount_dollars campaigner_photo reason_for_supporting)

  attr_accessible \
    :template_name,
		:name, # refers to campaign name
		:tagline,
		:goal_amount,
		:main_image,
		:remove_main_image, # for carrierwave
		:video_url,
		:vimeo_video_id,
		:youtube_video_id,
		:summary,
		:body

  has_many :campaigns

  def customizable_attribute?(attribute_name)
    CUSTOMIZABLE_ATTR.include? attribute_name.to_sym
  end
end
