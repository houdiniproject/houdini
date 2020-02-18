class MiscEventInfo < ActiveRecord::Base
  belongs_to :event
  attr_accessible :hide_cover_fees_option
end
