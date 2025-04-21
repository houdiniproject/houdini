# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module Phone
    def self.readable(number)
      # Convert to:
      # (505) 263-6320
      # or:
      # 263-6320
      return "" if number.blank?

      stripped = number.gsub(/[-\(\)\.\s]/, "") # remove extra chars and space
      if stripped.length == 10
        "(#{stripped[0..2]}) #{stripped[3..5]}-#{stripped[6..9]}"
      elsif stripped.length == 7
        "#{stripped[0..2]}-#{stripped[3..6]}"
      else
        number
      end
    end
  end; end
