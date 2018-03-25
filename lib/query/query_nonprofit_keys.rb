require 'qx'

module QueryNonprofitKeys

  def self.get_key(npo_id, key_name)
    query = Qx.select(key_name)
      .from(:nonprofit_keys)
      .where({'nonprofit_id' => npo_id})
      .execute
    raise ActiveRecord::RecordNotFound.new("Nonprofit key does not exist: #{key_name}") if query.empty?
		Cypher.decrypt(JSON.parse query.first[key_name])
  end

end
