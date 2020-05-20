# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module QueryNonprofitKeys
  def self.get_key(npo_id, key_name)
    query = Qx.select(key_name)
              .from(:nonprofit_keys)
              .where('nonprofit_id' => npo_id)
              .execute
    raise ActiveRecord::RecordNotFound, "Nonprofit key does not exist: #{key_name}" if query.empty?

    Cypher.decrypt(JSON.parse(query.first[key_name]))
  end
end
