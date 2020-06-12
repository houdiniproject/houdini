# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Refund < ApplicationRecord
  Reasons = %i[duplicate fraudulent requested_by_customer].freeze
  # :amount, # int
  # :comment, # text
  # :reason, # str ('duplicate', 'fraudulent', or 'requested_by_customer')
  # :stripe_refund_id,
  # :disbursed, # boolean (whether this refund has been counted in a payout)
  # :failure_message, # str (accessor for storing the Stripe error message)
  # :user_id, :user, # user who made this refund
  # :payment_id, :payment, # negative payment that records this refund
  # :charge_id, :charge

  attr_accessor :failure_message

  belongs_to :charge
  belongs_to :payment

  scope :not_disbursed, -> { where(disbursed: [nil, false]) }
  scope :disbursed, -> { where(disbursed: [true]) }
end
