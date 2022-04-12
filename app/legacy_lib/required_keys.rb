# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# Given a hash and an array of keys
# Raise an argument error if any keys are missing from the hash

class RequiredKeys

  def initialize(hash, keys)
    missing = keys.select{|k| hash[k].nil?}
    raise ArgumentError.new("Missing keys: #{missing}") if missing.any?
  end
end
