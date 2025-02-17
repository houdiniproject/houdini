# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# A payment represents the event where a nonprofit receives money from a supporter
# If connected to a charge, this represents money potentially debited to the nonprofit's account
# If connected to an offsite_payment, this is money the nonprofit is recording for convenience.

class Payment < ApplicationRecord
  belongs_to :supporter
  belongs_to :nonprofit
  has_one :charge
  has_one :offsite_payment
  has_one :refund
  has_one :dispute
  belongs_to :donation
  has_many :tickets
  has_one :campaign, through: :donation
  has_many :events, through: :tickets
  has_many :payment_payouts
  has_many :charges

  has_one :stripe_charge

  has_one :subtransaction, through: :subtransaction_payment
  has_one :trx, through: :subtransaction_payment
end
