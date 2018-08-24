# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscellaneousNpInfo < ActiveRecord::Base

  attr_accessible \
  :donate_again_url,
  :change_amount_message,
  :supporter_default_address_strategy #manual, always_first, always_last

  belongs_to :nonprofit
end
