# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# A Charge represents a potential debit to a nonprofit's account on a credit card donation action.

class Charge < ApplicationRecord
  # :amount,
  # :fee,
  # :stripe_charge_id,
  # :status

  has_one :campaign, through: :donation
  has_one :recurring_donation, through: :donation
  has_many :tickets
  has_many :events, through: :tickets
  has_many :refunds
  has_many :disputes
  belongs_to :supporter
  belongs_to :card
  belongs_to :direct_debit_detail
  belongs_to :nonprofit
  belongs_to :donation
  belongs_to :payment

  has_one :stripe_charge, through: :payment

  scope :paid, -> { where(status: %w[available pending disbursed]) }
  scope :not_paid, -> { where(status: [nil, "failed"]) }
  scope :available, -> { where(status: "available") }
  scope :pending, -> { where(status: "pending") }
  scope :disbursed, -> { where(status: "disbursed") }

  def paid?
    status.in?(%w[available pending disbursed])
  end
end
