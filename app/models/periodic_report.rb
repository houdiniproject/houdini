# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReport < ApplicationRecord
  # active # boolean,
  # report_type # string,
  # period # string,
  # users,
  # nonprofit_id

  belongs_to :nonprofit, required: true
  has_and_belongs_to_many :users
  belongs_to :nonprofit_s3_key

  validate :valid_report_type?
  validate :valid_period?
  validate :valid_nonprofit_s3_key?
  validate :valid_users?

  scope :active, -> { where(active: true) }

  # run the report
  delegate :run, to: :adapter

  private

  AVAILABLE_REPORT_TYPES = [:failed_recurring_donations, :cancelled_recurring_donations, :active_recurring_donations_to_csv, :started_recurring_donations_to_csv].freeze
  AVAILABLE_PERIODS = [:last_month, :all].freeze

  private_constant :AVAILABLE_REPORT_TYPES
  private_constant :AVAILABLE_PERIODS

  def valid_report_type?
    errors.add(:report_type, "must be a supported report type") unless AVAILABLE_REPORT_TYPES.include? report_type&.to_sym
  end

  def valid_period?
    errors.add(:period, "must be a supported period") unless AVAILABLE_PERIODS.include? period&.to_sym
  end

  def valid_nonprofit_s3_key?
    errors.add(:nonprofit_s3_key, "must belong to the nonprofit set via :nonprofit") if nonprofit_s3_key.present? && nonprofit_s3_key.nonprofit != nonprofit
  end

  def valid_users?
    errors.add(:users, "must be a list of users") if users.none?
    users_authorized_to_have_report?
  end

  def users_authorized_to_have_report?
    users.each do |user|
      unless nonprofit.users.include?(user) || user.roles&.pluck(:name)&.include?("super_admin")
        errors.add(:users, "must be a user of the nonprofit or a super admin")
      end
    end
  end

  def adapter
    PeriodicReportAdapter.build({report_type: report_type, nonprofit_id: nonprofit_id, period: period, users: users, nonprofit_s3_key: nonprofit_s3_key, filename: filename})
  end
end
