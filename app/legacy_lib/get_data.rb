# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module GetData

	def self.chain(obj, *methods)
		methods.each do |m|
			if m.is_a?(Array)
				params = m[1..-1]
				m = m[0]
			end

			if obj != nil && obj.respond_to?(m)
				obj = obj.send(m, *params)
			elsif obj.respond_to?(:has_key?) && obj.has_key?(m)
				obj = obj[m]
			else
				return nil
			end
		end
		return obj
	end

  def self.hash(h, *keys)
		keys.each do |k|
			if h.has_key?(k)
				h = h[k]
			else
				return nil
			end
		end
		return h
  end
end

