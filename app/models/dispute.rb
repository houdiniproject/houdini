# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Dispute < ApplicationRecord
  Reasons = %i[unrecognized duplicate fraudulent subscription_canceled product_unacceptable product_not_received unrecognized credit_not_processed goods_services_returned_or_refused goods_services_cancelled incorrect_account_details insufficient_funds bank_cannot_process debit_not_authorized general].freeze

  Statuses = %i[needs_response under_review won lost lost_and_paid].freeze
  # :gross_amount, # int
  # :charge_id,
  # :charge,
  # :payment_id,
  # :payment,
  # :status,
  # :reason

  belongs_to :charge
  belongs_to :payment
end
