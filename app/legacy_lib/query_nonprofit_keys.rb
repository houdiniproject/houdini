# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryNonprofitKeys
  KEY_NAMES = ["mailchimp_token"]

  def self.get_key(npo_id, key_name)
    raise ActiveRecord::RecordNotFound.new("Nonprofit key does not exist: #{key_name}") unless KEY_NAMES.include?(key_name.to_s)
    item = Nonprofit.find(npo_id).nonprofit_key&.public_send(key_name.to_s)
    raise ActiveRecord::RecordNotFound.new("Nonprofit key does not exist: #{key_name}") unless item
    item
  end
end
