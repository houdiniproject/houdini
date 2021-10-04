# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# Given a hash and an array of keys
# Raise an argument error if any keys are missing from the hash

class RequiredKeys
  def initialize(hash, keys)
    missing = keys.select { |k| hash[k].nil? }
    raise ArgumentError, "Missing keys: #{missing}" if missing.any?
  end
end
