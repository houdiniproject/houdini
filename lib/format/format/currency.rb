# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Format
  module Currency
    # Converts currency units into subunits.
    # @param [String] units
    # @return [Integer]
    def self.dollars_to_cents(units)
      (units.delete(',').gsub(Houdini.intl.currencies[0], '').to_f * 100).to_i
    end

    # Converts currency subunits into units.
    # @param [Integer] subunits
    # @return [String]
    def self.cents_to_dollars(subunits)
      (subunits.to_f / 100.0).to_s
                             .gsub(/^(\d+)\.0$/, '\1') # remove trailing zero if no decimals (eg. "1.0" -> "1")
                             .gsub(/^(\d+)\.(\d)$/, '\1.\20') # add a second zero if single decimal (eg. "9.9" -> "9.90")
    end
end; end
