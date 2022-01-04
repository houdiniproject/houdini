# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Hash
  def keep_keys(*keys)
    keys = keys.map(&:to_s)
    clone.delete_if { |k, _v| !keys.include?(k.to_s) }
  end

  def keep_keys!(*keys)
    keys = keys.map(&:to_s)
    delete_if { |k, _v| !keys.include?(k.to_s) }
  end
end
