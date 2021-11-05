class MiscEventInfo < ActiveRecord::Base
  belongs_to :event
  attr_accessible :hide_cover_fees_option, :custom_get_tickets_button_label
end
