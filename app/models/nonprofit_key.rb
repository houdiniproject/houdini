# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# This is really just for mailchimp keys.

# Actually handled through InsertNonprofitKeys
class NonprofitKey < ApplicationRecord
  belongs_to :nonprofit, optional: false

  validates :mailchimp_token, presence: true

  def mailchimp_token
    read_attribute(:mailchimp_token).nil? ? nil : Cypher.decrypt(read_attribute(:mailchimp_token))
  end

  def mailchimp_token=(access_token)
    write_attribute(:mailchimp_token, access_token.nil? ? nil : Cypher.encrypt(access_token))
  end
end
