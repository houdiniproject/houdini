# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Construct < Struct

	def self.new(hash)
		keys = hash.keys
		vals = hash.values
		return super(*keys).new(*vals)
	end

	def expand(hash)
		return Construct.new(self.to_h.merge(hash))
	end

end
