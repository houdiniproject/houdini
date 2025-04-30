# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# A FeeStructure summarizes a set of various Stripe rates and surcharges to use when applied to a card and a transaction.
#
# !@attribute brand
# 	@return [String,nil] the card brands to apply to cards to if this is the most specific brand provider in the set of FeeStructures for a FeeEra.
#     If this is nil, this is the least specific FeeStructure.
#
# !@attribute stripe_fee
# 	@return [BigNumber] the base stripe percentage fee that should apply to charges using the FeeStructure
#
# !@attribute flat_fee
# 	@return [Integer] the flat fee in cents which should be applied to charges using this FeeStructure
#
# !@attribute [r] international_surcharge_fee
# 	@return [BigDecimal] the additional percentage which should apply to charges for cards which are not in local_country

class FeeStructure < ApplicationRecord
  belongs_to :fee_era

  validates :flat_fee,
    numericality: {only_integer: true, greater_than_or_equal_to: 0},
    presence: true

  validates :stripe_fee,
    numericality: {greater_than_or_equal_to: 0, less_than: 1},
    presence: true

  validates_presence_of :fee_era

  delegate :charge_international_fee?, :international_surcharge_fee, to: :fee_era

  # @param [Hash] opts
  # @option opts [#brand, #country] :source  the source to use for calculating the fee
  # @option opts [Numeric] :platform_fee  the platform percentage fee to add to the given fee structure
  # @option opts [Integer] :amount  the amount of the transaction in cents
  # @option opts [Integer] :flat_fee (0) the flat platform fee to add to the given fee structure

  def calculate_fee(opts = {})
    FeeCalculation.calculate(opts.merge(fee_structure: self))
  end

  # @param [Hash] opts
  # @option opts [#brand] :source  the source to use for calculating the fee
  # @option opts [Integer] :amount  the amount of the transaction in cents
  def calculate_stripe_fee(opts = {})
    StripeFeeCalculation.calculate(opts.merge(fee_structure: self))
  end

  class FeeCalculation
    include ActiveModel::Validations
    attr_accessor :source, :platform_fee, :flat_fee, :amount, :fee_structure

    validates :source, :platform_fee, :amount, presence: true
    validates_numericality_of :platform_fee, less_than: 1.0, greater_than_or_equal_to: 0.0
    validates_numericality_of :amount, greater_than: 0, is_integer: true
    validate :validate_source_is_source_like

    def initialize(args = {})
      @platform_fee = args[:platform_fee]
      @source = args[:source]
      @flat_fee = args[:flat_fee] || 0
      @amount = args[:amount]
      @fee_structure = args[:fee_structure]
    end

    def calculate
      raise ArgumentError.new(errors.full_messages) unless valid?

      fee_surcharge = fee_structure.stripe_fee + BigDecimal(platform_fee)
      if fee_structure.charge_international_fee?(source)
        fee_surcharge += fee_structure.international_surcharge_fee
      end

      (BigDecimal(amount) * fee_surcharge).ceil + fee_structure.flat_fee + flat_fee
    end

    def self.calculate(args = {})
      FeeCalculation.new(args).calculate
    end

    private

    def validate_source_is_source_like
      errors.add(:source, "must respond to #brand") unless source.respond_to?(:brand)
      errors.add(:source, "must respond to #country") unless source.respond_to?(:country)
    end
  end

  class StripeFeeCalculation
    include ActiveModel::Validations
    attr_accessor :source, :amount, :fee_structure

    validates :source, :amount, :fee_structure, presence: true
    validates_numericality_of :amount, greater_than: 0, is_integer: true
    validate :validate_source_is_source_like

    def initialize(args = {})
      @source = args[:source]
      @amount = args[:amount]
      @fee_structure = args[:fee_structure]
    end

    def calculate
      raise ArgumentError.new(errors.full_messages) unless valid?
      fee_surcharge = fee_structure.stripe_fee
      if fee_structure.charge_international_fee?(source)
        fee_surcharge += fee_structure.international_surcharge_fee
      end

      (BigDecimal(amount) * fee_surcharge).ceil + fee_structure.flat_fee
    end

    def self.calculate(args = {})
      StripeFeeCalculation.new(args).calculate
    end

    private

    def validate_source_is_source_like
      errors.add(:source, "must respond to #brand") unless source.respond_to?(:brand)
      errors.add(:source, "must respond to #country") unless source.respond_to?(:country)
    end
  end
end
