class Tracking < ActiveRecord::Base
  attr_accessible :utm_campaign, :utm_content, :utm_medium, :utm_source

  belongs_to :donation
end
