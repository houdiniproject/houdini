# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "timespan"

class RecurringDonation < ApplicationRecord
  # :amount, # int (cents)
  # :active, # bool (whether this recurring donation should still be paid)
  # :paydate, # int (fixed date of the month for monthly recurring donations)
  # :interval, # int (interval of time, ie the '3' in '3 months')
  # :time_unit, # str ('month', 'day', 'week', or 'year')
  # :start_date, # date (when to start this recurring donation)
  # :end_date, # date (when to deactivate this recurring donation)
  # :n_failures, # int (how many times the charge has failed)
  # :edit_token, # str / uuid to validate the editing page, linked from their email client
  # :cancelled_by, # str email of user/supporter who made the cancellation
  # :cancelled_at, # datetime of user/supporter who made the cancellation
  # :donation_id, :donation,
  # :nonprofit_id, :nonprofit,
  # :supporter_id #used because things are messed up in the datamodel

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: [false, nil]) }
  scope :monthly, -> { where(time_unit: "month", interval: 1) }
  scope :annual, -> { where(time_unit: "year", interval: 1) }

  belongs_to :donation
  belongs_to :nonprofit
  has_many :charges, through: :donation
  has_one :card, through: :donation
  has_one :supporter, through: :donation
  has_one :recurrence

  validates :paydate, numericality: {less_than: 29}, allow_blank: true
  validates :donation_id, presence: true
  validates :nonprofit_id, presence: true
  validates :start_date, presence: true
  validates :interval, presence: true, numericality: {greater_than: 0}
  validates :time_unit, presence: true, inclusion: {in: Timespan::Units}
  validates_associated :donation

  delegate :designation, :dedication, to: :donation

  def most_recent_charge
    charges&.max_by(&:created_at)
  end

  def most_recent_paid_charge
    charges&.find_all(&:paid?)&.max_by(&:created_at)
  end

  def total_given
    charges.find_all(&:paid?).sum(&:amount) if charges
  end
end
