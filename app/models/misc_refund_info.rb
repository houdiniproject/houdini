# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscRefundInfo < ApplicationRecord
  attr_accessible :is_modern,
    :stripe_application_fee_refund_id

  belongs_to :refund
end
