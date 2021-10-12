# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReport < ActiveRecord::Base

  # active # boolean,
  # report_type # string,
  # period # string,
  # user_id,
  # nonprofit_id

  belongs_to :nonprofit

  validate :valid_report_type?
  validate :valid_period?
  
  validates :user_id, presence: true
  validates :nonprofit_id, presence: true

  scope :active, -> { where(active: true) }

  def adapter
    PeriodicReportAdapter.build({ report_type: report_type, nonprofit_id: nonprofit_id, period: period, user_id: user_id })
  end

  private

  AVAILABLE_REPORT_TYPES = [:failed_recurring_donations].freeze
  AVAILABLE_PERIODS = [:last_month].freeze

  private_constant :AVAILABLE_REPORT_TYPES
  private_constant :AVAILABLE_PERIODS

  def valid_report_type?
    errors.add(:report_type, 'must be a supported report type') unless AVAILABLE_REPORT_TYPES.include? report_type.to_sym
  end

  def valid_period?
    errors.add(:period, 'must be a supported period') unless AVAILABLE_PERIODS.include? period.to_sym
  end
end
