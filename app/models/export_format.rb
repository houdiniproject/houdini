# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ExportFormat < ApplicationRecord
  # name - string that refers to the name of the nonprofit
  # date_format - a string that refers to the desired date format
  # show_currency - boolean that decides whether the currency should be displayed or not
  # custom_columns_and_values - customizes values and columns from the export

  belongs_to :nonprofit

  validates :name, presence: true
  validates :nonprofit_id, presence: true

  validates_with PostgresqlDateFormatValidator, {attribute_name: :date_format}

  validate :valid_custom_columns_and_values?

  after_validation :normalize_custom_columns

  private

  ALLOWED_COLUMNS_TO_HAVE_NAMES_CUSTOMIZED = [
    "payments.date",
    "payments.gross_amount",
    "payments.fee_total",
    "payments.net_amount",
    "payments.kind",
    "donations.anonymous",
    "supporters.anonymous",
    "donations.anonymous OR supporters.anonymous",
    "campaigns_for_export.name",
    "campaigns_for_export.id",
    "campaigns_for_export.creator_email",
    "campaign_gift_options.name",
    "events_for_export.name",
    "payments.id",
    "offsite_payments.check_number",
    "donations.comment",
    "misc_payment_infos.fee_covered",
    "donations.created_at"
  ].freeze

  ALLOWED_COLUMNS_TO_HAVE_VALUES_CUSTOMIZED = [
    "payments.kind",
    "donations.designation",
    "donations.anonymous",
    "supporters.anonymous",
    "donations.anonymous OR supporters.anonymous",
    "donations.comment",
    "campaigns_for_export.name",
    "campaign_gift_options.name",
    "events_for_export.name",
    "donations.comment",
    "misc_payment_infos.fee_covered"
  ].freeze

  private_constant :ALLOWED_COLUMNS_TO_HAVE_NAMES_CUSTOMIZED
  private_constant :ALLOWED_COLUMNS_TO_HAVE_VALUES_CUSTOMIZED

  def valid_custom_columns_and_values?
    return if custom_columns_and_values.nil?
    custom_columns_and_values.keys.each do |column|
      if ALLOWED_COLUMNS_TO_HAVE_NAMES_CUSTOMIZED.include? column
        unless (custom_columns_and_values[column].include? "custom_name") || (custom_columns_and_values[column].include? "custom_values")
          errors.add(:custom_columns_and_values, "you need to include a 'custom_name' or 'custom_values' key to customize #{column} column")
        end
        if (!ALLOWED_COLUMNS_TO_HAVE_VALUES_CUSTOMIZED.include? column) && (custom_columns_and_values[column].include? "custom_values")
          errors.add(:custom_columns_and_values, "column #{column} can't have its values customized")
        end
      else
        errors.add(:custom_columns_and_values, "column #{column} does not exist or is not available to be customized")
      end
    end
  end

  def normalize_custom_columns
    custom_columns_and_values&.each do |column, customizations|
      customizations&.each do |customization, customization_subject|
        if customization == "custom_name"
          custom_columns_and_values[column]["custom_name"] =
            insert_trailing_double_quotes(customization_subject)
        end
      end
    end
  end

  def insert_trailing_double_quotes(value)
    value.insert(0, '"').insert(-1, '"')
  end
end
