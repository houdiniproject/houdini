# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscellaneousNpInfo < ApplicationRecord

  attr_accessible \
  :donate_again_url,
  :change_amount_message,
  :hide_cover_fees

  belongs_to :nonprofit
  
  validates_inclusion_of :fee_coverage_option_config, in: ['auto', 'manual', 'none', nil]
end
