# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# FeeEra describes a period of time where a given set of fee structures apply.
#
# @attribute! start_time
#   @return [DateTime|nil] the time where the FeeEra should begin being applied.
#     If nil, the era began at the earliest possible time. (Time.at(0)). At minimum, start_time or end_time must be set.

# @attribute! end_time
#   @return [DateTime|nil] the time where the FeeEra should stop being applied.
#     If nil, the era ends at the latest possible time, i.e. way in the future. At minimum, start_time or end_time must be set.
#
# @attribute! fee_structures
#   @return One or more FeeStructure objects that apply during the FeeEra
class FeeEra < ApplicationRecord
  has_one :fee_coverage_detail_base, validate: true

  has_many :fee_structures do
    def find_by_source(source)
      unless source.respond_to?(:brand) and source.respond_to?(:country)
        raise ArgumentError,
          "source must be a valid Stripe::Source, Stripe::Card or similar"
      end
      brand_found = select { |i| i.brand == source.brand }.first
      return brand_found if brand_found

      blank_source = select { |i| i.brand.blank? }.first
      if blank_source.nil?
        raise ArgumentError,
          "source must be a valid Stripe::Source, Stripe::Card or similar"
      end
      blank_source
    end
  end

  validates_associated :fee_structures, :fee_coverage_detail_base

  validates :international_surcharge_fee,
    numericality: {greater_than_or_equal_to: 0, less_than: 1}, allow_nil: true

  validates :international_surcharge_fee, presence: {if: -> { local_country.present? }}

  validates :fee_coverage_detail_base, presence: true
  #
  # Should an international surcharge be added
  #
  # @param [#country] source the source which has a country to check against
  #
  # @return [Boolean] true if an international fee should be added, false otherwise
  #
  def charge_international_fee?(source)
    local_country.present? && source.country != local_country
  end

  # Whether the given time is included in the FeeEra. true if it does, false otherwise.
  # @param at [DateTime,nil]
  def in_era?(at = nil)
    at ||= Time.current
    test_start_time = start_time || Time.at(0)
    test_end_time = end_time || Time.new(9999, 1)
    (test_start_time...test_end_time).cover? at
  end

  # Given a time, find the FeeEra that time is within.
  # @param at [DateTime,nil] the time to use for searching for a FeeEra. Default of for current time
  def self.find_by_time(at = nil)
    at ||= Time.current
    era_result = all.select { |i| i.in_era?(at) }
    raise ActiveRecord::RecordNotFound if era_result.none?
    era_result.first
  end

  # Given a source, use the card network on the source in order to find the appropriate FeeStructure.
  # The code works as follows:
  # 1. Is there a FeeStructure in fee_structures with the brand of source? If so, we return that FeeStructure.
  # 2. Return the FeeStructure in fee_structures which has no set brand.
  # @param [#brand,#country] a Stripe::Source, Stripe::Card or similar
  # @returns [FeeStructure]
  def find_fee_structure_by_source(source)
    fee_structures.find_by_source(source)
  end

  # @param [Hash] opts
  # @option opts [#brand, #country] :source  the source to use for calculating the fee
  # @option opts [Numeric] :platform_fee  the platform percentage fee to add to the given fee structure
  # @option opts [Integer] :amount  the amount of the transaction in cents
  # @option opts [Integer] :flat_fee (0) the flat platform fee to add to the given fee structure

  def calculate_fee(opts = {})
    find_fee_structure_by_source(opts[:source]).calculate_fee(opts)
  end

  # @param [Hash] opts
  # @option opts [#brand] :source  the source to use for calculating the fee
  # @option opts [Integer] :amount  the amount of the transaction in cents
  def calculate_stripe_fee(opts = {})
    find_fee_structure_by_source(opts[:source]).calculate_stripe_fee(opts)
  end

  # @param [Hash] opts
  # @option opts [Stripe::Charge] :charge the Stripe::Charge to use for calculating the fee
  # @option opts [Stripe::Refund] :refund the Stripe::Refund for
  # @option opts [Stripe::ApplicationFee] :application_fee the Stripe::ApplicationFee for this Charge
  def calculate_application_fee_refund(opts = {})
    application_fee = opts[:application_fee]
    charge = opts[:charge]
    refund = opts[:refund]
    stripe_fee_to_reserve = refund_stripe_fee? ? 0 : calculate_stripe_fee(amount: charge.amount, source: charge.source)
    max_fee_to_refund = application_fee.amount - stripe_fee_to_reserve
    refundable_fee_left = max_fee_to_refund - application_fee.amount_refunded
    if refundable_fee_left <= 0
      return 0
    end

    if charge.refunded
      refundable_fee_left
    else
      portion_of_charge_refunded = BigDecimal(refund.amount) / BigDecimal(charge.amount)
      amount_to_refund = (BigDecimal(max_fee_to_refund) * portion_of_charge_refunded).floor
      (amount_to_refund >= refundable_fee_left) ? refundable_fee_left : amount_to_refund
    end
  end

  # @param [Hash] opts
  # @option opts [Time] :charge_date the date that the charge occurred for purposes of finding the correct fee era
  # @option opts [Stripe::Charge] :charge the Stripe::Charge to use for calculating the fee
  # @option opts [Stripe::Refund] :refund the Stripe::Refund for
  # @option opts [Stripe::ApplicationFee] :application_fee the Stripe::ApplicationFee for this Charge
  def self.calculate_application_fee_refund(opts = {})
    FeeEra.find_by_time(opts[:charge_date]).calculate_application_fee_refund(opts)
  end

  # @param [Hash] opts
  # @option opts [#brand, #country] :source  the source to use for calculating the fee
  # @option opts [Numeric] :platform_fee  the platform percentage fee to add to the given fee structure
  # @option opts [Integer] :amount  the amount of the transaction in cents
  # @option opts [Integer] :flat_fee (0) the flat platform fee to add to the given fee structure
  # @option opts [DateTime,nil] :at (nil) the time to use for searching for a FeeEra. Default of current time
  def self.calculate_fee(opts = {})
    FeeEra.find_by_time(opts[:at]).calculate_fee(opts)
  end

  # @param [Hash] opts
  # @option opts [#brand, #country] :source  the source to use for calculating the fee
  # @option opts [Integer] :amount  the amount of the transaction in cents
  # @option opts [DateTime,nil] :at (nil) the time to use for searching for a FeeEra. Default of current time
  def self.calculate_stripe_fee(opts = {})
    FeeEra.find_by_time(opts[:at]).calculate_stripe_fee(opts)
  end

  def self.current
    FeeEra.find_by_time
  end
end
