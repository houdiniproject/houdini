# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryNonprofitKeys
  def self.get_key(npo_id, key_name)
    item = Nonprofit.find(npo_id).nonprofit_key&.send(key_name.to_sym)
    raise ActiveRecord::RecordNotFound.new("Nonprofit key does not exist: #{key_name}") unless item
    item
  end
end
