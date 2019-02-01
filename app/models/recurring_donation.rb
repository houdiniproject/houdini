# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RecurringDonation < ApplicationRecord

  attr_accessible \
    :amount, # int (cents)
    :active, # bool (whether this recurring donation should still be paid)
    :paydate, # int (fixed date of the month for monthly recurring donations)
    :interval, # int (interval of time, ie the '3' in '3 months')
    :time_unit, # str ('month', 'day', 'week', or 'year')
    :start_date, # date (when to start this recurring donation)
    :end_date, # date (when to deactivate this recurring donation)
    :n_failures, # int (how many times the charge has failed)
    :edit_token, # str / uuid to validate the editing page, linked from their email client
    :cancelled_by, # str email of user/supporter who made the cancellation
    :cancelled_at, # datetime of user/supporter who made the cancellation
    :donation_id, :donation,
    :nonprofit_id, :nonprofit,
    :supporter_id #used because things are messed up in the datamodel

  scope :active,   -> {where(active: true)}
  scope :inactive, -> {where(active: [false,nil])}
  scope :monthly,  -> {where(time_unit: 'month', interval: 1)}
  scope :annual,   -> {where(time_unit: 'year', interval: 1)}

  belongs_to :donation
  belongs_to :nonprofit
  has_many :charges, through: :donation
  has_one :card, through: :donation
  has_one :supporter, through: :donation

  validates :paydate, numericality: {less_than: 29}, allow_blank: true
  validates :donation_id, presence: true
  validates :nonprofit_id, presence: true
  validates :start_date, presence: true
  validates :interval, presence: true, numericality: {greater_than: 0}
  validates :time_unit, presence: true, inclusion: {in: Timespan::Units}
  validates_associated :donation

  def most_recent_charge
    if (self.charges)
      return self.charges.sort_by { |c| c.created_at }.last()
    end
  end

  def most_recent_paid_charge
    if (self.charges)
      return self.charges.find_all {|c| c.paid?}.sort_by { |c| c.created_at }.last()
    end
  end

  def total_given
    if (self.charges)
      return self.charges.find_all(&:paid?).sum(&:amount)
    end

  end

  # XXX let's make these monthly_totals a query
  # Or just push it into the front-end
  def self.monthly_total
    self.all.map(&:monthly_total).sum
  end

  def monthly_total
    multiple = {
      'week' => 4,
      'day' => 30,
      'year' => 0.0833
    }[self.interval] || 1
    return self.donation.amount * multiple
  end

end
