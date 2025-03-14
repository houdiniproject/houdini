# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module Currency
    # Converts currency units into subunits.
    # @param [String] units
    # @return [Integer]
    def self.dollars_to_cents(units)
      (units.delete(",").gsub(Houdini.intl.currencies[0], "").to_f * 100).to_i
    end

    # Converts currency subunits into units.
    # @param [Integer] subunits
    # @return [String]
    def self.cents_to_dollars(subunits)
      (subunits.to_f / 100.0).to_s
        .gsub(/^(\d+)\.0$/, '\1') # remove trailing zero if no decimals (eg. "1.0" -> "1")
        .gsub(/^(\d+)\.(\d)$/, '\1.\20') # add a second zero if single decimal (eg. "9.9" -> "9.90")
    end

    # Print money based on informed currency
    # @param [Integer] cents the amount of money to be printed
    # @param [String] unit the currency that will be used to print
    # @param [Boolean] sign whether it should show the sign of the amount
    # @param [Boolean] use_precision whether it should have two decimal cases
    # @return [String] the text with the amount of money in the informed currency (Ex.: $10.00)
    def self.print_currency(cents, unit = "EUR", sign = true, use_precision = false)
      dollars = cents.to_f / 100.0
      dollars = ActiveSupport::NumberHelper.number_to_currency(dollars, unit: unit.to_s, precision: (!use_precision && dollars.round == dollars) ? 0 : 2)
      dollars = dollars[1..-1] unless sign
      dollars
    end
  end; end
