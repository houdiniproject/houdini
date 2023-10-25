# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscRecurringDonationInfo < ApplicationRecord
  belongs_to :recurring_donation
  attr_accessible :fee_covered
end
