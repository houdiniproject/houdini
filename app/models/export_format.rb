# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ExportFormat < ActiveRecord::Base
  # name - string that refers to the name of the nonprofit
  # date_format - a string that refers to the desired date format
  # show_currency - boolean that decides whether the currency should be displayed or not
  # custom_columns_and_values - customizes values and columns from the export

  belongs_to :nonprofit

  validates :name, presence: true
  validates :nonprofit_id, presence: true

  validate :valid_custom_columns_and_values?

  private

  ALLOWED_CUSTOM_EXPORT_COLUMNS = [
    'payments.date',
    'payments.gross_amount',
    'payments.fee_total',
    'payments.net_amount',
    'payments.kind',
    'donations.anonymous',
    'supporters.anonymous',
    'campaigns_for_export.name',
    'campaigns_for_export.id',
    'campaigns_for_export.creator_email',
    'campaign_gift_options.name',
    'events_for_export.name',
    'payments.id',
    'offsite_payments.check_number',
    'donations.comment',
    'misc_payment_infos.fee_covered'
  ].freeze

  private_constant :ALLOWED_CUSTOM_EXPORT_COLUMNS

  def valid_custom_columns_and_values?
    return if custom_columns_and_values.nil?
    custom_columns_and_values.keys.each do |column|
      if ALLOWED_CUSTOM_EXPORT_COLUMNS.include? column
        unless (custom_columns_and_values[column].include? 'custom_name') || (custom_columns_and_values[column].include? 'custom_values')
          errors.add(:custom_columns_and_values, "you need to include a 'custom_name' or 'custom_values' key to customize #{column} column")
        end
      else
        errors.add(:custom_columns_and_values, "column #{column} does not exist or is not available to be customized")
      end
    end
  end
end
