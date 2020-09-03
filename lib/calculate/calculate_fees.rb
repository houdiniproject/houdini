# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CalculateFees
  BaseFeeRate = 0.022 # 2.2%
  PerTransaction = 30 # 30 cents

  DEFAULT = {platform_fee: 0.0}
  def self.for_single_amount(amount, **args)
    args = DEFAULT.merge(args).merge({amount: amount})
    FeeCalculation.new(args).for_single_amount
  end

  def self.reverse_for_single_amount(amount, **args)
    args = DEFAULT.merge(args).merge({amount: amount})
    FeeCalculation.new(args).reverse_for_single_amount
   
  end

  class FeeCalculation
    include ActiveModel::Validations
    attr_accessor :source, :platform_fee, :switchover_date, :amount

    validates :source, :platform_fee, :amount, presence: true
    validates_numericality_of :platform_fee, less_than: 1.0, greater_than_or_equal_to: 0.0
    validates_numericality_of :amount, greater_than: 0, is_integer: true
    validate :validate_is_source_stripe_object

    def initialize(**args)
      @platform_fee = args[:platform_fee]
      @source = args[:source]
      @switchover_date = args[:switchover_date]
      @amount = args[:amount]
    end

    def for_single_amount
      if valid?
        fee_rate, flat_per_transaction_rate = fee_and_per_transaction_rate

        return (fee_rate * BigDecimal.new(amount.to_s)).ceil.to_i + flat_per_transaction_rate
      else
        raise "Errors: #{errors.full_messages}"
      end
    end

    def reverse_for_single_amount
      if valid?
        unless after_switchover?
          fee_rate, flat_per_transaction_rate = fee_and_per_transaction_rate
        
          return (((amount + flat_per_transaction_rate) / (1 - fee_rate))).ceil.to_i - amount
        else
          return ( Settings.flat_fee_coverage_percent * BigDecimal.new(amount)).ceil.to_i
        end
      else
        raise "Errors: #{errors.full_messages}"
      end
    end

    private 
    
    def validate_is_source_stripe_object
      unless source.is_a?(Stripe::Source) || source.is_a?(Stripe::Card)
        errors.add(:source, "must be a Stripe::Source or Stripe::Card object")
      end
    end

    def amex_card?
      source.brand == 'American Express'
    end

    def us_card?
      source.country == 'US'
    end

    def foreign_card?
      !us_card?
    end

    def fee_and_per_transaction_rate
      fee_rate = BigDecimal.new(platform_fee.to_s)
      if amex_card? && after_switchover?
        fee_rate += 0.035
      else
        fee_rate += 0.022
      end
      
      if foreign_card? && after_switchover?
        fee_rate += 0.01
      end
      flat_per_transaction_rate = 30
      if amex_card? && after_switchover?
        flat_per_transaction_rate = 0
      end

      return fee_rate, flat_per_transaction_rate
    end

    def after_switchover?
      !switchover_date || Time.now >= switchover_date
    end
  end
end

