# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
