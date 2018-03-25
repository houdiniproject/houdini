class MiscellaneousNpInfo < ActiveRecord::Base

  attr_accessible \
  :donate_again_url,
  :change_amount_message

  belongs_to :nonprofit
end
