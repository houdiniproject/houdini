# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
