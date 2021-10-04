# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module GetData
  def self.chain(obj, *methods)
    methods.each do |m|
      if m.is_a?(Array)
        params = m[1..-1]
        m = m[0]
      end

      if !obj.nil? && obj.respond_to?(m)
        obj = obj.send(m, *params)
      elsif obj.respond_to?(:has_key?) && obj.key?(m)
        obj = obj[m]
      else
        return nil
      end
    end
    obj
  end

  def self.hash(h, *keys)
    keys.each do |k|
      if h.key?(k)
        h = h[k]
      else
        return nil
      end
    end
    h
  end
end
