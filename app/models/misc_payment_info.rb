# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscPaymentInfo < ActiveRecord::Base
  belongs_to :payment
  attr_accessible :fee_covered
end
