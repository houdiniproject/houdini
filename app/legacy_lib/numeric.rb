# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Numeric
  # Works like Numeric#floor but uses an offset other than 1. Ex: 6.floor_for_delta(5) -> 5
  # @param [Integer] delta the integer offsets from zero to round down to
  # @return [Integer]
  def floor_for_delta(delta)
    raise ArgumentError, "delta must be a positive integer" unless delta.is_a?(Integer) && delta > 0

    (self % delta).zero? ? self : ((to_i / delta)) * delta
  end

  # Works like Numeric#ceil but uses an offset other than 1. Ex: 6.floor_for_delta(5) -> 10
  # @param [Integer] delta the integer offsets from zero to round up to
  # @return [Integer]
  def ceil_for_delta(delta)
    raise ArgumentError, "delta must be a positive integer" unless delta.is_a?(Integer) && delta > 0

    (self % delta).zero? ? self : ((floor.to_i / delta) + 1) * delta
  end
end
