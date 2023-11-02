# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Hash
  # Prefills a new Hash from the values in other_hash. If a value in other_hash is nil, then it isn't copied over.
  def self.with_defaults_unless_nil(other_hash)
    try_convert(other_hash.compact)
  end
end
