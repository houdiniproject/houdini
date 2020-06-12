# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Construct < Struct
  def self.new(hash)
    keys = hash.keys
    vals = hash.values
    super(*keys).new(*vals)
  end

  def expand(hash)
    Construct.new(to_h.merge(hash))
  end
end
